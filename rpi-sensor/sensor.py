import requests
from gpiozero import Button

def update_status(response):
    requests.patch("http://172.20.10.6:5000/parkings/t469avtVcnLTtxdcbHMW/spot/10", data={})
    print("Changed id 10 status succesfully!")


def break_beam_callback(channel):
    if beam.is_pressed:
        try:
            response = requests.get("http://172.20.10.6:5000/parkings")
            # print(f"API Response: {response.status_code} - {response.text}")
            update_status(response)
            
        except:
            print(f"Failed to reach the API.")
        print("beam unbroken")
    else:
        print("beam broken")

beam = Button(17, pull_up=True)
beam.when_pressed = break_beam_callback
beam.when_released = break_beam_callback

input("Press enter to quit\n")