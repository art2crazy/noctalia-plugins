Originally forked from noctalia-plugins/world-clock by Lokize.
It's a playground for learning QML, etc, but also a place to implement changes the original author didn't want to do. 

Most of the original plugin functionality is still there.

Changes:
- modify Tooltip to display all timezones 
- remove 5 zone limit 
- remove hardcoded zones in favor of user input (valid IANA zones)
- use moment.js & moment-timezone.js to calculate time/date
- settings:
    - add custom tooltip date/time format 
    - add separate Alias and Timezones fields 

To-do:
- allow editing existing timezones and aliases
- allow changing sort order of existing timezones
