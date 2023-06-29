module _a(left, right) {
   _ = _fa(left, right);
}

function _fa(left, right) =
    assert(str(left) == str(right), str("Expected: ", right, ", got: ", left));


function coalesce(a1, a2, a3=undef) =
  (a1 != undef) ? a1 :
  (a2 != undef) ? a2 :
  a3;

map = function (v, f) [for(x=v) f(x)]; 
    
// zip: [A] -> [B] -> [(A, B)]
zip = function (a, b)
    let (count = len(a), _ = _fa(len(a), len(b)))
    [for (index = [0 : count-1]) [a[index], b[index]]];