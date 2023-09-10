include <utils.scad>

/* 
    This file introduces types system used in this library. I've come up with this
    as OpenSCAD has no control over types. There are only a few simple buitin types and 
    there is no support for more complex ones. I tried to make it more haskel-like.
  
    Object of a given type is represented with a vector. 
    
    [ <TYPE_IDENTIFIER>, <FIELD_1_VALUE>, <FIELD_2_VALUE>, ... ]
    
    Its first element is the type identifier and is used 
    to distinguish one type from others. The rest of the vector are the objects attributes.
    
    In order to create object of the type `Type` use the following:
    
    Type(<FIELD_1_VALUE>, <FIELD_2_VALUE>)
    
    Attributes are accessed via getters. Each getter performs assertion that passed object
    is of valid type.
    
    get_field_1(object) -> <FIELD_1>
    get_field_2(object) -> <FIELD_2>
    
    As long as those Types are used as intented, they should provide (quite) stress-free experience.
*/

/*  ======= TYPES =======  */

/*  State keeps track of everything that may influence the next drawing - 
    current rotation, position, how the line is drawn etc. 
*/
// State: RotMatrix -> Position -> LineWidth -> State
function State(rotation_matrix, position, line_width) =
    ["__State__", rotation_matrix, position, line_width];

/*  Operation defines transition between two states. This transition may result in something drawn on screen. Allowed operations are defined in <primitives.scad> file. */
// Operation: (OperationType, [Arg]) -> Operation
function Operation(type, args) = assert(is_op_type(type)) ["__Operation__", type, args];

/*  Step keeps state and the transition to the next state. Notice that it's all that is needed to draw something on screen. We know were and how to draw (state) and what to draw (operation). */
// Step: (State, Operation) -> Step
function Step(state, op) = assert(is_state(state)) assert(is_op(op), op)
    ["__Step__", state, op];

/*  There are effects in drawing that cannot be represented as a transition between two states. Furthermore, OpenSCAD implements them as a scope. Filling the drawing with color is one of such effects. We call those effects "Modes". As we have no real variables in OpenSCAD, we have to use those scopes, but we have to pass sequences of Steps to them. Mode executes some Operation over steps. 
*/
// Mode: (OperationType, [Step]) -> Mode
function Mode(op_type, states) = 
    assert(is_op_type(op_type))
    ["__Mode__", op_to_mode(op_type), states];

/*  Marks allowed types of Modes. ModeTypes are actually kind of OperationTypes, but our typing system does not allow inheritance. */
// _ModeType: str -> _ModeType
function _ModeType(type_str) = ["__ModeType__", type_str]; 

/* Marks allowed types of Operations. Contains also types for Modes, that can be translated to ModeType. */
// OperationType: str -> OperationType
function _OperationType(type_str) = ["__OperationType__", type_str]; 

/* Nested allows to combine list of operations together with the control over types.
   Greatly simplifies loops and modes implementation. 
*/
// Nested: [Operation] -> Nested
function Nested(body) = ["__Nested__", body];

/* Figure is an alias, it allow users to make variables with complex shapes, */    
// Figure: [Operation] -> Nested
function Figure(ops) = Nested(ops);

/* ======= DISCRIMINANTS ======= */

// is: Any -> str -> bool
is = function(obj, type) obj[0] == type;

is_state = function(obj) is(obj, "__State__");
is_op = function (obj) is(obj, "__Operation__");
is_step = function(obj) is(obj, "__Step__");
is_mode = function(obj) is(obj, "__Mode__");
is_mode_type = function (obj) is(obj, "__ModeType__");
is_op_type = function (obj) is(obj, "__OperationType__");
is_nested = function(obj) is(obj, "__Nested__");

/* ======= GETTERS ======= */

// get_rotation_matrix: State -> RotMatrix
function get_state_rotation_matrix(state) = assert(is_state(state), state) state[1];
// get_position: State -> Position
function get_state_position(state) = assert(is_state(state), state) state[2];
// get_line_width: State -> LineWidth
function get_state_line_width(state) = assert(is_state(state), state) state[3];

// get_op_type: Operation -> fun
function get_op_type(op) = assert(is_op(op), op) op[1];
// get_op_args: Operation -> [Arg]
function get_op_args(op) = assert(is_op(op), op) op[2];

// get_step_state: Step -> State
function get_step_state(step) = assert(is_step(step), step) step[1];
// get_step_op: Step -> Operation
function get_step_op(step) = assert(is_step(step), step) step[2];
// get_step_op: Step -> OperationType
function get_step_type(step) = assert(is_step(step), step) get_op_type(get_step_op(step));
// get_step_args: Step -> [Arg]
function get_step_args(step) = assert(is_step(step), step) get_op_args(get_step_op(step));

// get_mode_type: Mode -> ModeType
function get_mode_type(mode) = assert(is_mode(mode), mode) mode[1];
// get_mode_steps: Mode -> [Step]
function get_mode_steps(mode) = assert(is_mode(mode), mode) mode[2];

// flatten: Nested -> [Operation]
function flatten(body) = assert(is_nested(body)) body[1];
