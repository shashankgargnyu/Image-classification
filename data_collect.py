import csv
import os
import requests
import urllib

fid = csv.reader(open('imagenet.synset.obtain_synset_list.txt','r'))
synset_list = [row for row in fid]
categories=synset_list[0:1000]
wnids  = [val for sublist in categories for val in sublist]
print wnids
base_url='http://www.image-net.org/api/text/imagenet.synset.geturls.getmapping?wnid=';
url=[base_url+wnid for wnid in wnids]
print url

newpath = '/Users/amitesh/Desktop/ML Project/'
#for k in range(len(url)):

import urllib2
class HeadRequest(urllib2.Request):
    def get_method(self):
        return 'HEAD'


for k in range(2):
    current_dir=newpath+wnids[k]
    if not os.path.exists(current_dir):
        os.makedirs(current_dir)
        os.chdir(current_dir)
        
        
    data_id_link = {}
    #data = urllib.urlopen(url[k]).read() 
    #print data
    
    data = urllib.urlopen(url[k])
    for line in data:
        if len(line.strip()) != 0:
            splitLine = line.split()
            data_id_link[splitLine[0]] = splitLine[1]
        else:
            break
    #print data_id_link
    count =0
    for id, link in data_id_link.items():
        try:
            response = requests.get(link)
        except:
            continue
        
        if 'photo_unavailable.png'in response.url:
            continue
        elif response.status_code!=200:
            continue
        elif '.jpg'== response.url[-4:]:
            print link
            try:
                response1= urllib2.urlopen(HeadRequest(link))
                maintype= response1.headers['Content-Type'].split(';')[0].lower()
                if maintype in ('image/png', 'image/jpeg', 'image/gif'):
                    urllib.urlretrieve(link, id+".jpg")
                    count+=1
                else:
                    continue
            except Exception:
                pass

        else:
            continue
        if count==99:
            break
        
    #newDict
     
    #print data