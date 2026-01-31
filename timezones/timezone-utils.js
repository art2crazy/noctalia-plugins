// Import moment.js and moment-timezone from the same plugin directory
.import "moment.js" as MomentJS
.import "moment-timezone.js" as MomentTimezone


function isMomentAvailable() {
    return typeof moment !== 'undefined'
}

function getTimeInTimezone(tz, format) {
    try {
        // Check if moment is available in global scope
        if (isMomentAvailable()) {
            format = format === 'undefined' || format === '' ? "HH:mm, ddd DD-MMM" : format;
            return moment().tz(tz).format(format)
        } else {
            return "moment.js not available"
        }
    } catch (e) {
        return "invalid timezone"
    }
}

function isZoneValid(tz) {
  if (!isMomentAvailable()) { return false; }
  return moment.tz.zone(tz) !== null;
}
