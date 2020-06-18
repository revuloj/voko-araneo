// https://stackoverflow.com/questions/7563169/detect-which-word-has-been-clicked-on-within-a-text
// https://github.com/davatron5000/Lettering.js
// https://stackoverflow.com/questions/56989692/how-to-set-text-decoration-underline-on-hover-over-text-areas-each-word
// https://www.w3schools.com/cssref/sel_selection.asp
// https://www.w3schools.com/cssref/css3_pr_user-select.asp

$(".wx_click").click(function (e) {
    var selection = window.getSelection();
    if (!selection || selection.rangeCount < 1) return true;
    var range = selection.getRangeAt(0);
    var node = selection.anchorNode;
    var word_regexp = /^\w*$/;

    // Extend the range backward until it matches word beginning
    while ((range.startOffset > 0) && range.toString().match(word_regexp)) {
      range.setStart(node, (range.startOffset - 1));
    }
    // Restore the valid word match after overshooting
    if (!range.toString().match(word_regexp)) {
      range.setStart(node, range.startOffset + 1);
    }

    // Extend the range forward until it matches word ending
    while ((range.endOffset < node.length) && range.toString().match(word_regexp)) {
      range.setEnd(node, range.endOffset + 1);
    }
    // Restore the valid word match after overshooting
    if (!range.toString().match(word_regexp)) {
      range.setEnd(node, range.endOffset - 1);
    }

    var word = range.toString();
});​


// https://developer.mozilla.org/en-US/docs/Web/API/Selection/modify

$(".wordclick").click(function() {
    // Gets clicked on word (or selected text if text is selected)
    var t = '';
    if (window.getSelection && (sel = window.getSelection()).modify) {
        // Webkit, Gecko
        var s = window.getSelection();
        if (s.isCollapsed) {
            s.modify('move', 'forward', 'character');
            s.modify('move', 'backward', 'word');
            s.modify('extend', 'forward', 'word');
            t = s.toString();
            s.modify('move', 'forward', 'character'); //clear selection
        }
        else {
            t = s.toString();
        }
    } else if ((sel = document.selection) && sel.type != "Control") {
        // IE 4+
        var textRange = sel.createRange();
        if (!textRange.text) {
            textRange.expand("word");
        }
        // Remove trailing spaces
        while (/\s$/.test(textRange.text)) {
            textRange.moveEnd("character", -1);
        }
        t = textRange.text;
    }
    alert(t);
});

