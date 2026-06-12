#!/usr/bin/env python3
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / 'Encrypted_Design'

# Header template matching existing package files
HEADER_TMPL = '''/*-----------------------------------------------------------------
File name     : {name}
Description   :
Notes         :
-------------------------------------------------------------------
-----------------------------------------------------------------*/

'''

EXTS = ['.sv', '.svh']

def has_header(text):
    # detect existing /*---- header near top
    return text.lstrip().startswith('/*') and 'File name' in text.splitlines()[0:6][0:6].__str__()

def file_has_header(text):
    # simpler: look for 'File name' in first 12 lines
    first = '\n'.join(text.splitlines()[:12])
    return 'File name' in first and 'Description' in first


def main():
    updated = []
    if not ROOT.exists():
        print('Encrypted_Design folder not found at', ROOT)
        return
    for lab in sorted(ROOT.iterdir()):
        if not lab.is_dir():
            continue
        if not lab.name.lower().startswith('lab'):
            continue
        # walk lab folder
        for dirpath, dirs, files in os.walk(lab):
            for fn in files:
                p = Path(dirpath) / fn
                if p.suffix.lower() in EXTS:
                    try:
                        text = p.read_text()
                    except Exception as e:
                        print('skip read', p, e)
                        continue
                    if file_has_header(text):
                        continue
                    # prepend header
                    hdr = HEADER_TMPL.format(name=p.name)
                    new_text = hdr + text
                    p.write_text(new_text)
                    updated.append(str(p.relative_to(Path.cwd())))
    print('Updated files:')
    for u in updated:
        print(u)

if __name__ == '__main__':
    main()
