# mapme.at.sh

This script allows you to update your location on MapMe.At using DNS.
You will need to have an account on that site and set up a shortcode
on the Account page.

Clone this repository then symlink mapme.at.sh into your path.

# Instructions

You must set your shortcode before you can use this script. This
will then be stored in plaintext on your system:
```
  mapme.at.sh shortcode [<shortcode>]
```

Once shortcode has been set you can update location using either
a favourite label or a raw lat/lon, e.g.:
```
  mapme.at.sh home
  mapme.at.sh 56.493773 0.439453
```

If you have a USB GPS device you can get the latitude and longitude
from there. Assuming the device is already set up and configured
simply try something similar to the following:
```
  mapme.at.sh /dev/tty.HOLUXGPSlim236-SPPslave-1
```
