import os
import json

def read_env(self):
    "Check, read environmental files"

    curr_path = os.path.dirname(os.path.abspath(__file__))

    with open(curr_path+"/api_endpoints.json") as endpoints:
        endp_vals = json.load(endpoints)
        station_url = endp_vals["station_url"]
        wms_url = endp_vals["wms_url"]
        wfs_url = endp_vals["wfs_url"]

    with open(curr_path+'/unit_conversion.json') as units:
        unit_vals = json.load(units)
        for i in unit_vals:
            print(i)

    return 