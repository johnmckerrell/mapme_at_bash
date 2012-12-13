# mapme.at.sh

This script allows you to update your location on MapMe.At using DNS.
You will need to have an account on that site and set up a shortcode
on the Account page.

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
