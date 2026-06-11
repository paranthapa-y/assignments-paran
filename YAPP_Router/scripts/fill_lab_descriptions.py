#!/usr/bin/env python3
import re
from pathlib import Path
import os

ROOT = Path(__file__).resolve().parents[1] / 'Encrypted_Design'
EXTS = ['.sv', '.svh']

def infer_description(text, path):
    """Infer a meaningful description based on file content and path."""
    low = text.lower()
    fn = path.name
    
    # Check specific file patterns first (before generic testbench check)
    
    # scoreboard
    if 'scoreboard' in fn.lower() or re.search(r'class\s+\w*[Ss]coreboard', text):
        return "Scoreboard for checking DUT output correctness against expected results"
    
    # reference model
    if 'reference' in fn.lower():
        return "Reference model implementing golden behavior for DUT functionality"
    
    # virtual sequencer
    if 'virtual_sequencer' in fn.lower():
        return "Virtual sequencer for coordinating stimulus across multiple agents"
    
    # virtual sequences
    if 'virtual_seqs' in fn.lower() or 'vseq' in fn.lower():
        return "Virtual sequence library for high-level test stimulus generation"
    
    # wrapper
    m = re.search(r'module\s+(?P<name>\w+)', text)
    if m and 'wrapper' in fn.lower():
        name = m.group('name')
        return f"Wrapper module {name} instantiating DUT and connecting interfaces"
    
    # Now check testbench path
    if '/tb/' in str(path).replace('\\','/') or 'tb' in path.parts:
        if 'top' in fn.lower() and 'dut' in fn.lower():
            return "Top-level testbench module instantiating DUT and connecting all interfaces"
        if 'top' in fn.lower():
            return "Top-level testbench file for simulation"
        if 'dut' in fn.lower():
            return "Module wrapper for DUT instantiation and interface connections"
        if 'test_lib' in fn.lower() or 'vtest_lib' in fn.lower():
            return "Test sequence library defining stimulus and scenarios"
        if 'router_tb' in fn.lower():
            return "Testbench module coordinating test environment and DUT"
        return "Testbench/support file for simulation"
    
    # package
    if re.search(r'\bpackage\b', text):
        return f"Package containing type definitions and macros for verification environment"
    
    # interface
    m = re.search(r'interface\s+(?P<name>\w+)\s*[;(]', text)
    if m:
        iface_name = m.group('name')
        return f"Interface {iface_name} defining signals to connect DUT and testbench"
    
    # environment
    m = re.search(r'class\s+(?P<name>\w+)\s+extends\s+uvm_env', text)
    if m:
        name = m.group('name')
        return f"UVM environment {name} composing agents, scoreboards, and reference model"
    
    # module (RTL)
    if m and '/rtl/' in str(path).replace('\\','/'):
        name = m.group('name')
        return f"RTL implementation module {name}"
    
    # module (TB)
    if m:
        name = m.group('name')
        return f"Module {name} for verification environment"
    
    # uvm classes
    m = re.search(r'class\s+(?P<name>\w+)\s+extends\s+(?P<base>uvm_\w+)', text)
    if m:
        name = m.group('name')
        base = m.group('base')
        if 'monitor' in base.lower():
            return f"UVM monitor {name} observing transactions on DUT interfaces"
        if 'driver' in base.lower():
            return f"UVM driver {name} driving stimulus transactions into the DUT"
        if 'sequencer' in base.lower() or 'sequencer' in name.lower():
            return f"UVM sequencer {name} generating and sending transactions to driver"
        if 'agent' in base.lower():
            return f"UVM agent {name} composing sequencer, driver, and monitor"
        if 'sequence' in base.lower():
            return f"UVM sequence {name} generating test stimulus scenarios"
        return f"UVM component {name} ({base}) in verification environment"
    
    # transaction/packet class
    if 'class' in text and ('transaction' in fn.lower() or 'packet' in fn.lower()):
        return "Transaction/packet class defining test stimulus structure"
    
    # sequences library
    if any(x in fn.lower() for x in ['seq_lib','seq.sv','seqs.sv']):
        return "Sequence library defining stimulus patterns and test scenarios"
    
    # fallback
    return f"Source file {fn}"


def update_file_descriptions(p: Path):
    """Update Description field in header and add inline comment."""
    try:
        text = p.read_text()
    except Exception as e:
        print(f"  Error reading {p}: {e}")
        return False
    
    # Check for header pattern and update Description line
    lines = text.split('\n')
    desc_line_idx = -1
    header_end_idx = -1
    
    # Find Description line and header end
    for i, line in enumerate(lines):
        if 'Description' in line and ':' in line and i < 10:
            desc_line_idx = i
        if '*/' in line and i < 10 and 'Description' in '\n'.join(lines[max(0, i-5):i+1]):
            # This */ closes the header block
            header_end_idx = i + 1
            break
    
    if desc_line_idx == -1 or header_end_idx == -1:
        return False
    
    # Infer description
    new_desc = infer_description(text, p)
    
    # Update Description line
    lines[desc_line_idx] = f"Description   : {new_desc}"
    
    # Find first major declaration (module/class/interface) and add inline comment
    first_decl_idx = -1
    for i in range(header_end_idx, len(lines)):
        if re.match(r'\s*(module|class|interface)\s+\w+', lines[i]):
            first_decl_idx = i
            break
    
    if first_decl_idx > 0:
        # Check if there's already a comment right before
        prev_line = lines[first_decl_idx - 1].strip()
        if prev_line and not prev_line.startswith('//') and not prev_line.endswith('*/'):
            # Insert comment line
            comment_line = f"// {new_desc}"
            lines.insert(first_decl_idx, comment_line)
    
    new_text = '\n'.join(lines)
    p.write_text(new_text)
    return True


def main():
    updated = []
    if not ROOT.exists():
        print(f'Encrypted_Design not found at {ROOT}')
        return
    
    for lab in sorted(ROOT.iterdir()):
        if not lab.is_dir():
            continue
        if not lab.name.lower().startswith('lab'):
            continue
        
        print(f"\nProcessing {lab.name}...")
        for dirpath, dirs, files in os.walk(lab):
            for fn in sorted(files):
                p = Path(dirpath) / fn
                if p.suffix.lower() not in EXTS:
                    continue
                
                if update_file_descriptions(p):
                    rel_path = str(p.relative_to(ROOT))
                    updated.append(rel_path)
                    print(f"  ✓ {rel_path}")
    
    print(f"\n{'='*60}")
    print(f"Total files updated: {len(updated)}")
    if updated:
        print('\nUpdated files:')
        for u in updated:
            print(f"  - {u}")


if __name__ == '__main__':
    main()
