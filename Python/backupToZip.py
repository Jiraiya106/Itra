#! python3

import zipfile, os

def backupToZip(folder):
    folder = os.path.abspath(folder)
    number = 1
    while True:
        zipFilename = os.path.basename(folder) + '_' + str(number) + '.zip'
        if not os.path.exists(zipFilename):
            break
        number += 1
    print('Create file %s...' % (zipFilename))
    backupZip = zipfile.ZipFile(zipFilename, 'w')

    for foldername, subfolders, filenames in os.walk(folder):
        print('Add file of dir %s...' % (foldername))
        backupZip.write(foldername)
        for filename in filenames:
            os.path.basename(folder) + '_'
            if filename.startswith('Python') and filename.endswith('.zip'):
                continue
            backupZip.write(os.path.join(foldername, filename))
    backupZip.close()
    print('Ready')
            
backupToZip('/home/ITRANSITION.CORP/e.ilin/Work/Itra/Python')