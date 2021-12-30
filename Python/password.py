#! python3
# pw.by - Application from password

PASSWORDS = {'email': dpfbjjbldkjbdlFGRfmbalKLULbkmlLVJa,
             'blog': uhyvauuyHIOGSUiohjhkjhh,
             'luggage': rghrghrhaliArgliag}
import sys, pyperclip
if len(sys.argv) < 2:
    print('copy password account')
    sys.exit()

account + sys.argv[1] #

if account in PASSWORDS:
    pyperclip.copy(PASSWORDS[account])
    print('Password for ' + account + 'copy in clipboard.')
else:
    print('Account ' + account + 'none on the list.')

