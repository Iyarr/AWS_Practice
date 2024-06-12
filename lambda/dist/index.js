"use strict";
var s = Object.defineProperty;
var a = Object.getOwnPropertyDescriptor;
var d = Object.getOwnPropertyNames;
var l = Object.prototype.hasOwnProperty;
var m = (r, e) => {
    for (var o in e) s(r, o, { get: e[o], enumerable: !0 });
  },
  p = (r, e, o, t) => {
    if ((e && typeof e == "object") || typeof e == "function")
      for (let n of d(e))
        !l.call(r, n) &&
          n !== o &&
          s(r, n, {
            get: () => e[n],
            enumerable: !(t = a(e, n)) || t.enumerable,
          });
    return r;
  };
var c = (r) => p(s({}, "__esModule", { value: !0 }), r);
var i = {};
m(i, { handler: () => f });
module.exports = c(i);
var f = async (r) => ({
  statusCode: 200,
  body: JSON.stringify("Hello from Lambda!"),
});
0 && (module.exports = { handler });
//# sourceMappingURL=index.js.map
