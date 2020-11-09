---
title: "Save your thumbs with Strava Kudos Automation"
date: 2020-11-09T21:14:20+11:00
draft: false
Author: "Daniel Barrett"
---

As a software developer, I am always looking for ways to automate mundane tasks in my life. As a casual athlete I am always looking for ways to show my support to my friends on [Strava](https://www.strava.com) by kudos'ing (ie. liking) their activities. So one day I thought why not automate my kudos'ing activities on Strava. This blog post explains the method and code I used to create this kudos'ing automation.

# Requirements

- A Linux based operating system (eg. Ubuntu).
- Docker installed on the system.
- Docker-compose installed on the system.

# The Approach

We will need two containers, the first being a selenium container which we will use to drive the browser automation and the second being a python container which will drive the selenium container and command it to log in to our Strava accounts and give kudos to the activities. 

# The Selenium container

We run a selenium standalone firefox container and expose port 4444 so we can connect to it from our host system.

```yaml
version: "3.7"
services:
  webdriver:
    image: selenium/standalone-firefox
    ports:
      - "4444:4444"
    shm_size: '2gb'
```

# Python Automation

Now we enter the meaty part of this post where we scrape the Strava website by logging in by automatically entering our username and password, then scroll through our activity feed and click on the `Kudo` button to give kudos to the activity.

Note we require the following python packages installed:

```text
selenium
```

Save that into a file called requirements.txt at the root of your project directory.

# Login to Strava

We read in the username and password from the environment variables, then enter the email and password elements and send the key commands to type. Then we hit the login button.
The reason we read in the username and password from the environment variables is to avoid hard coding confidential data into the application and to also make the application reusable for different users. This follows the [12 Factor Application principles](https://12factor.net/). 

```python
from strava.driver import driver
import os

USER = os.getenv('USER')
PASSWORD = os.getenv('PASSWORD')

driver.get('https://www.strava.com/login')
username = driver.find_element_by_name('email')
username.clear()
username.send_keys(USER)
password = driver.find_element_by_name('password')
password.clear()
password.send_keys(PASSWORD)
login = driver.find_element_by_id('login-button')
login.click()
```

Save this code in a file called login.py in a directory called Strava. In the next section, we will import the driver object.

# Kudo the Activity Feed

We use the css selector `button.js-add-kudo` to find all of the kudos buttons on the activity feed on the screen. Then we loop through all of these elements and like them all, then proceed to scroll by executing the javascript `window.scrollTo(0,document.body.scrollHeight)` . Out of respect to Strava, we only scroll through our activity feed five times, and if before then we find no kudos buttons we exit out. 

```python
import time
from strava.login import driver

kudo_count = 0
for _ in range(5):
    time.sleep(5)
    kudo = driver.find_elements_by_css_selector('button.js-add-kudo')
    if len(kudo) == 0:
        break
    for button in kudo:
        driver.execute_script("arguments[0].click();", button)
        kudo_count += 1

    driver.execute_script("window.scrollTo(0,document.body.scrollHeight)")

print(kudo_count)

driver.close()
```

Put this code in a file at the root of your project directory called kudos.py

## Dockerfile

We build a Python-based docker image to install the requirements and run the code. This Dockerfile looks like:

```dockerfile
FROM python:3.8-alpine

WORKDIR /app

COPY . .

RUN pip3 install -r requirements.txt

ENTRYPOINT ["python3", "/app/kudos.py"]
```

# Execute the automation

For simplicity, we automate the building, and running of the docker containers into one convenient script:

```bash
#!/usr/bin/env bash
set -euo pipefail

docker-compose up -d --remove-orphans

cleanup() {
    docker-compose down
}
trap cleanup SIGINT
trap cleanup EXIT

# Wait for the selenium container to be listening on port 4444
until nc -vzw 2 localhost 4444; do sleep 5; done

export SERVER=http://localhost:4444/wd/hub

docker build . -t kudos
docker run --network=host -e USER=$1 -e PASSWORD=$2 -e SERVER kudos
```

Save this script into a file called `run.sh`.

Invoke the script with the command:

```
bash run.sh <STRAVA EMAIL ADDRESS> <STRAVA PASSWORD>
```

# Schedule the Kudos Automation

If we add the path variable to the start of the script:

```bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
```

then create a crontab entry by running the command:

```bash
crontab -e
```

and enter the following on a newline:

```text
* 7-20 * * * run.sh
```

we will schedule the kudos automation to run every hour between 7 am and 8 pm. 
