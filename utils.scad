module _a(left, right, echo_fun=undef) {
   _ = _fa(left, right, echo_fun);
}

function _fa(left, right, echo_fun=undef) =
    let (eval_left = str(left), eval_right = str(right), comp = eval_left == eval_right)
    echo_fun ? 
        comp ? undef : 
            let (_1 = echo("Expected:"), _2 = echo_fun(right), _3 = echo("Got:"), _4 = echo_fun(left)) 
                assert(false) :
        comp ? undef :
            let (_1 = echo("Expected:"), _2 = echo(right), _3 = echo("Got:"), _4 = echo(left)) 
                assert(false);


function coalesce(a1, a2, a3=undef) =
  (a1 != undef) ? a1 :
  (a2 != undef) ? a2 :
  a3;

map = function (v, f) [for(x=v) f(x)]; 
    
// zip: [A] -> [B] -> [(A, B)]
zip = function (a, b)
    let (count = len(a), _ = _fa(len(a), len(b)))
    [for (index = [0 : count-1]) [a[index], b[index]]];