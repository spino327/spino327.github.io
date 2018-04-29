/**
 * Truncate string.
 *
 * @param elementName: selector.
 * @param maxLength: maximum length of the string
 */
function truncateElement(elementName, maxLength) {
  console.info('Truncating elements ' + elementName + " to " + maxLength);

  $(elementName).each(function () {
    var etext = $(this).text();
    if (etext.length >= maxLength) {
      etext = etext.substr(0, maxLength - 3) + "...";
    } else {
      var n = maxLength - etext.length;
      for (var i = 0; i < n; i=i+2) {
        etext = etext + " .";
      }
    }
    $(this).text(etext);
  });
}
