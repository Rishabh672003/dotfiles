float i, e, R, s;
vec3 q, p, d = vec3(FC.xy / r - vec2(.5, 0), 1);

for (q.zy--; i++ < 139.;) {
  o.rgb += hsv(.57, p.y, min(e * s, R) / 50.);
  s = 1.;
  p = q += d * e * R * .3;
  p = vec3(log2(R = length(p)) - t * .5, exp2(-p.z / R),
           atan(p.y, p.x) * s - cos(t) * .09);
  for (e = --p.y; s < 3e3; s += s)
    e += (dot(sin(p.zyy * s) - .6, .46 - sin(p * s))) / s * .2;
}
