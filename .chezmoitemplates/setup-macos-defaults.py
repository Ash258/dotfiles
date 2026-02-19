#!/usr/bin/env python3
import os
import json
import subprocess
from pathlib import Path
import sys
import re

class C:
   PURPLE = '\033[1;35;48m'
   CYAN = '\033[1;36;48m'
   BOLD = '\033[1;37;48m'
   BLUE = '\033[1;34;48m'
   GREEN = '\033[1;32;48m'
   YELLOW = '\033[1;33;48m'
   RED = '\033[1;31;48m'
   BLACK = '\033[1;30;48m'
   GREY = '\033[1;37;48m'
   WHITE = '\033[1;37;48m'
   UNDERLINE = '\033[4;37;48m'
   END = '\033[1;37;0m'

FALLBACK_VALUE = "<not set>"

def main():
    is_work_device: bool = "{{ .email }}".endswith("@outlook.com")
    is_work_device = not is_work_device
    tmpl_var: str = "{{ .chezmoi.sourceDir }}"
    if tmpl_var.startswith("{"): # Template was not evaluated, fallback to environment variable
        tmpl_var = f"{os.environ.get('HOME', '')}/.local/share/chezmoi"

    hostname = os.uname().nodename.split(".")[0] # Get hostname without domain
    chezmoi_defaults_path: Path = Path(tmpl_var)
    chezmoi_defaults_path = chezmoi_defaults_path / "internal_configs" / "macos" / "defaults"
    global_defaults = chezmoi_defaults_path / "global.json"
    hostname_defaults = chezmoi_defaults_path / f"{hostname}.json"

    if not global_defaults.is_file():
        print(C.GREY,"Global defaults file not found at: ", global_defaults, C.END)
        os.exit(0)

    glob: dict = {}
    with open(global_defaults, "r") as f:
        glob = json.load(f)

    # There will be either hostname override or work
    override: dict = {}
    file_to_override = hostname_defaults
    if is_work_device:
        file_to_override = chezmoi_defaults_path / "work.json"

    if file_to_override.is_file():
        print(f"Loading host specific override ({file_to_override.relative_to(chezmoi_defaults_path)}){C.END}")
        with open(file_to_override, "r") as f:
            override = json.load(f)

    domain_overriden: bool = False
    for domain, dkeys in glob.items():
        if domain in override:
            print(f"Domain '{domain}' is overridden by host-specific defaults{C.END}")
            domain_overriden = True

        for key, value in dkeys.items():
            if domain_overriden:
                if key in override[domain]:
                    print(f"Key '{key}' in domain '{domain}' is overridden by host-specific defaults{C.END}")
                    value = override[domain][key]

            deftype, value = get_datatype_from_config_value(value, key)
            if deftype is None:
                continue

            # Stolen from: https://github.com/ansible-collections/community.general/blob/34938ca1efe24d151c22ff136aa6acede95be2dc/plugins/modules/osx_defaults.py#L263
            read_key = subprocess.run(
                ["defaults", "read", domain, key],
                capture_output=True,
                text=True,
            )

            out = read_key.stdout.strip("\n").strip("\r").strip()
            if read_key.returncode != 0:
                if "does not exist" in read_key.stderr:
                    out = FALLBACK_VALUE

            # TODO: Could it be easier?
            value = _convert_type(deftype, value)
            if value is None:
                continue
            try:
                # TODO: Fix it, it should return
                current_value = _convert_type(deftype, out)
                if current_value is None:
                    continue
            except Exception as e:
                if deftype == "int" and out == FALLBACK_VALUE:
                    current_value = -20

            # print(f"DBG: {current_value} ({type(current_value)}) == {value} ({type(value)}) => {current_value == value}")
            if current_value == value:
                continue

            to_set = ""
            if deftype == "list":
                deftype = "array"
                to_set = value
            else:
                to_set = [str(value)]

            wrote_result = subprocess.run(
                (["defaults", "write", domain, key, f"-{deftype}"] + to_set),
                capture_output=True,
                text=True
            )

            if wrote_result.returncode != 0:
                print(f"{C.RED}Failed to set '{key}' in domain '{domain}' to '{value}': {wrote_result.stderr}{C.END}")
                continue
            print(f"{C.GREEN}Set '{key}' in domain '{domain}' to '{value}' (was: '{current_value}') {C.END}")

        domain_overriden = False

    print(f"{C.GREEN}All done{C.END}")


def get_datatype_from_config_value(value, key):
    deftype = ""
    v = ""
    if isinstance(value, bool):
        deftype = "bool"
        if value == True:
            v = "TRUE"
        else:
            v = "FALSE"
    elif isinstance(value, int):
        deftype = "int"
        if value == FALLBACK_VALUE:
            print("AHOJ")
            v = 9999
        v = value
    elif isinstance(value, str):
        deftype = "string"
        v = value
    elif isinstance(value, list):
        deftype = "list"
        v = value
    else:
        # Skip unsupported types for now
        print(f"""{C.RED}Unsupported key type for '{key}' with value {type(value)}{C.END}""")
        return None, value

    return deftype, v

def _convert_type(data_type, value):
    """Converts value to given type"""
    if data_type == "string":
        return str(value)
    elif data_type in ["bool", "boolean"]:
        if isinstance(value, (bytes, str)):
            value = value.lower()
        if value in [True, 1, "true", "1", "yes"]:
            return True
        elif value in [False, 0, "false", "0", "no"]:
            return False
    elif data_type in ["int", "integer"]:
        return int(value)
    elif data_type == "list":
        # https://github.com/ansible-collections/community.general/blob/34938ca1efe24d151c22ff136aa6acede95be2dc/plugins/modules/osx_defaults.py#L246-L258
        if isinstance(value, str):
            new = value.splitlines()
            new.pop(0)
            new.pop(-1)
            new = [re.sub('^ *"?|"?,? *$', "", x.replace('\\"', '"')) for x in new]
            return new
        return value
    else:
        print(f"{C.RED}Unsupported data type: {data_type}{C.END}")
        return None

if __name__ == "__main__":
    main()
