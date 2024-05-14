/sGuardPlus/slither_func2vec/slither/printers/summary/sguard_plus.py
if (contract.kind != "contract"):continue

kind attribute only exists for solc ^0.4.12
to run sguard, we set the compile to 0.4.12 if the pargma version is lower than that