# Autosizing Text to fit an SVG Element

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<svg version="1.2" viewBox="0 0 1000 500" width="1000" height="500" xmlns="http://www.w3.org/2000/svg" >

  <g id="g1" transform="translate(499,250)">
    <text id="t2" x="0" y="0" fill="#000" text-anchor="middle" alignment-baseline="middle">Mark</text>
  </g>
  <rect x="0" y="0" width="999" height="499" fill="none" stroke="#000" stroke-width="1">
  <script type="application/ecmascript">
    var width=1000, height=500;
    var textNode = document.getElementById("t2");
    var bb = textNode.getBBox();
    var widthTransform = width / bb.width;
    var heightTransform = height / bb.height;
    var value = widthTransform < heightTransform ? widthTransform : heightTransform;
    textNode.setAttribute("transform", "scale("+value+", "+value+")");
 </script>
</svg>
```

