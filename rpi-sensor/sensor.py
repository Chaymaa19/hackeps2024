import requests
from gpiozero import Button

def get_random_spot():
    try:
        response = requests.get("http://172.20.10.6:5000/parkings/t469avtVcnLTtxdcbHMW/available-spots")
        print(response.json())
        return response.json().get("selectedSpotId")
    except:
        print(f"Failed to reach the API random.")

def update_status(assigned_spot):
    print(type(assigned_spot))
    try:
        requests.patch(f"http://172.20.10.6:5000/parkings/t469avtVcnLTtxdcbHMW/spot/{assigned_spot}", data={})
        print(f"Changed id {assigned_spot} status succesfully!")
    except:
        print(f"Failed to reach the API update status.")

def break_beam_callback(channel):
    global car_is_entering  # Declare car_is_entering as global to modify it within the function
    global assigned_spot    # Declare assigned_spot as global if you want to modify it here

    print(car_is_entering)
    if beam.is_pressed:
        try:
            if car_is_entering:
                assigned_spot = get_random_spot()
                print(assigned_spot)
                car_is_entering = False  # Change the global car_is_entering variable here
                update_status(assigned_spot)
            else:
                update_status(assigned_spot)
                car_is_entering = True
            
        except:
            print(f"Failed to reach the API.")

        print("beam unbroken")
    else:
        print("beam broken")


if __name__ == "__main__":
    global assigned_spot 
    global car_is_entering
    
    assigned_spot = -1
    car_is_entering = True
    
    beam = Button(17, pull_up=True)
    beam.when_pressed = break_beam_callback
    beam.when_released = break_beam_callback

    input("Press enter to quit\n")
