import QtQuick 2.0
import MuseScore 3.0

MuseScore {
      menuPath: "Plugins.Notes.VowelsToNotes"
      description: "Map lyrics vowels to notes in a selection, like Guido of Arezzo."
      version: "0.1"
            
      onRun: {
            var curMeasure = null;
            var refMeasure = null;

            console.log("Starting VowelsToNotes.");
            
            if (!curScore) {
                  console.log("No score. Exiting.");
                  Qt.quit();
            } else if (curScore.selection.elements.length < 3) {
                  console.log("Selection too small. Exiting.");
                  Qt.quit();
            } else {
                  var cursor = curScore.newCursor(); // get selection
                  var v2n = {"a":null, "e":null, "i":null, "o":null, "u":null, "y":null};
                  cursor.rewind(2);       // end of selection
                  var endTick = cursor.tick;
                  if (endTick == 0)
                        endTick = curScore.lastSegment.tick + 1;
                  cursor.rewind(1);       // beginning of selection

                  // Map first notes in selection to vowels.
                  for (var vowel in v2n) {
                        console.log("Vowel = "+vowel+", tick = "+cursor.tick);
                        if (cursor.element.type == Element.CHORD) {
                              v2n[vowel] = cursor.element.notes[0];
                        }
                        cursor.next();
                  }

                  // Apply map to remaining notes with lyrics.
                  while (cursor.segment != null && cursor.tick < endTick) {
                        if (cursor.element.type == Element.CHORD && cursor.element.lyrics.length > 0) {
                              for (var vowel in v2n) {
                                    if (cursor.element.lyrics[0].text.toLowerCase().indexOf(vowel) != -1) {
                                          // Update pitch and tonal pitch class (tpc)
                                          var note = cursor.element.notes[0];
                                          note.pitch = v2n[vowel].pitch;
                                          note.tpc = v2n[vowel].tpc;
                                          note.tpc1 = v2n[vowel].tpc1;
                                          note.tpc2 = v2n[vowel].tpc2;
                                          break;
                                    }     
                              }
                        }
                        cursor.next();
                  }
            }
            Qt.quit();
      }
}
