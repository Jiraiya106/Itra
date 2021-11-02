#! python3

def isPhoneNumber(text):
    if len(text) != 12:
        return False
    for i in range(0,3):
        if not text[i].isdecimal() :
            return False
    if text[3] != '-':
        return False
    for i in range(4, 7):
        if not text[i].isdecimal():
            return False
    if text[7] != '-':
        return False
    for i in range(8, 12):
        if not text[i].isdecimal():
            return False
    return True

message = 'Call me 415-555-1011. 415-555-9999 - phone number my office'

for i in range (len(message)):
    chuck = message[i:i+12]
    if isPhoneNumber(chuck):
       print('Number: ' + chuck)
print('Ready') 