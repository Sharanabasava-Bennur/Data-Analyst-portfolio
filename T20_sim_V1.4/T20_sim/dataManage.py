import pickle

dat = open('extractedData/allDataAdjusted', 'rb')
playersData = pickle.load(dat)
dat.close()