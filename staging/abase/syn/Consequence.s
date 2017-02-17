( function _Consequence_s_() {

'use strict';

  /**
   * @file Consequence.s - Advanced synchronization mechanism. wConsequence is able to solve any asynchronous problem
     replacing and including functionality of many other mechanisms, such as: Callback, Event, Signal, Mutex, Semaphore,
     Async, Promise.
   */

/*

 !!! move promise / event property from object to correspondent

 !!! test difference :

    if( err )
    return new wConsequence().error( err );

    if( err )
    throw _.err( err );

*/

/*

chainer :

1. ignore / use returned
2. append / prepend returned
3.

*/

if( typeof module !== 'undefined' )
{

  if( typeof wBase === 'undefined' )
  try
  {
    require( '../../abase/wTools.s' );
  }
  catch( err )
  {
    require( 'wTools' );
  }

  wTools.include( 'wProto' );
  wTools.include( 'wCopyable' );

}

//

var _ = wTools;
var Parent = null;
var Parent = Function;

  /**
   * Class wConsequence creates objects that used for asynchronous computations. It represent the queue of results that
   * can computation asynchronously, and has a wide range of tools to implement this process.
   * @class wConsequence
   */

  /**
   * Function that accepts result of wConsequence value computation. Used as parameter in methods such as got(), thenDo(),
    etc.
   * @param {*} err Error object, or any other type, that represent or describe an error reason. If during resolving
      value no exception occurred, it will be set to null;
     @param {*} value resolved by wConsequence value;
   * @callback wConsequence~Correspondent
   */

  /**
   * Creates instance of wConsequence
   * @example
     var con = new wConsequence();
     con.give( 'hello' ).got( function( err, value) { console.log( value ); } ); // hello

     var con = wConsequence();
     con.got( function( err, value) { console.log( value ); } ).give('world'); // world
   * @param {Object|Function|wConsequence} [options] initialization options
   * @returns {wConsequence}
   * @constructor
   * @see {@link wConsequence}
   */

var Self = function wConsequence( options )
{
  if( !( this instanceof Self ) )
  return new( _.routineJoin( Self, Self, arguments ) );

  Self.prototype.init.apply( this,arguments );

  var self = this;
  var wrap = function wConsequence( err,data )
  {
    _.assert( arguments.length === 0 || arguments.length === 1 || arguments.length === 2 )
    if( arguments.length === 2 )
    self.give( arguments[ 0 ],arguments[ 1 ] );
    else
    self.give( arguments[ 0 ] );
  }

  wrap.prototype = null;

  Object.setPrototypeOf( wrap, self );

  return wrap;
}

//

  /**
   * Initialises instance of wConsequence
   * @param {Object|Function|wConsequence} [o] initialization options
   * @private
   * @method pathCurrent
   * @memberof wConsequence#
   */

var init = function init( o )
{
  var self = this;

  // if( _.routineIs( o ) )
  // o = { all : o };

  _.mapComplement( self,self.Composes );

  if( self.constructor === Self )
  Object.preventExtensions( self );

  if( o )
  self.copy( o );

}

// --
// mechanics
// --

/**
 * Method created and appends correspondent object, based on passed options into wConsequence correspondents queue.
 *
 * @param {Object} o options object
 * @param {wConsequence~Correspondent|wConsequence} o.onGot correspondent callback
 * @param {Object} [o.context] if defined, it uses as 'this' context in correspondent function.
 * @param {Array<*>|ArrayLike} [o.argument] values, that will be used as binding arguments in correspondent.
 * @param {string} [o.id=null] id for correspondent function
 * @param {boolean} [o.thenning=false] If sets to true, then result of current correspondent will be passed to the next correspondent
    in correspondents queue.
 * @param {boolean} [o.persistent=false] If sets to true, then correspondent will be work as queue listener ( it will be
 * processed every value resolved by wConsequence).
 * @param {boolean} [o.tapping=false] enabled some breakpoints in debug mode;
 * @returns {wConsequence}
 * @private
 * @method _correspondentAppend
 * @memberof wConsequence#
 */

function _correspondentAppend( o )
{
  var self = this;
  var correspondent = o.correspondent;
  var id = o.id || correspondent ? correspondent.id : null || null;

  _.assert( arguments.length === 1 );
  _.assert( _.routineIs( correspondent ) || correspondent instanceof Self );

  if( _.routineIs( correspondent ) )
  {

    if( Config.debug )
    if( o.ifError || o.ifNoError )
    _.assert( correspondent.length <= 1 );

    if( o.context !== undefined || o.argument !== undefined )
    correspondent = _.routineJoin( o.context,correspondent,o.argument );

  }
  else
  {
    _.assert( o.context === undefined && o.argument === undefined );
  }

  /* */

  /* store */

  if( o.persistent )
  self._correspondentPersistent.push
  ({
    onGot : correspondent,
    id : id,
  });
  else
  self._correspondent.push
  ({
    onGot : correspondent,
    thenning : !!o.thenning,
    tapping : !!o.tapping,
    ifError :  !!o.ifError,
    ifNoError : !!o.ifNoError,
    debug : !!o.debug,
    id : id,
  });

  /* got */

  if( self.usingAsyncTaker )
  setTimeout( function()
  {

    if( self._message.length )
    self._handleGot();

  }, 0 );
  else
  {

    if( self._message.length )
    self._handleGot();

  }

  /* */

  return self;
}

// --
// chainer
// --

  /**
   * Method appends resolved value and error handler to wConsequence correspondents sequence. That handler accept only one
      value or error reason only once, and don't pass result of it computation to next handler (unlike Promise 'then').
      if got() called without argument, an empty handler will be appended.
      After invocation, correspondent will be removed from correspondents queue.
      Returns current wConsequence instance.
   * @example
       function gotHandler1( error, value )
       {
         console.log( 'handler 1: ' + value );
       };

       function gotHandler2( error, value )
       {
         console.log( 'handler 2: ' + value );
       };

       var con1 = new wConsequence();

       con1.got( gotHandler1 );
       con1.give( 'hello' ).give( 'world' );

       // prints only " handler 1: hello ",

       var con2 = new wConsequence();

       con2.got( gotHandler1 ).got( gotHandler2 );
       con2.give( 'foo' );

       // prints only " handler 1: foo "

       var con3 = new wConsequence();

       con3.got( gotHandler1 ).got( gotHandler2 );
       con3.give( 'bar' ).give( 'baz' );

       // prints
       // handler 1: bar
       // handler 2: baz
       //
   * @param {wConsequence~Correspondent|wConsequence} [correspondent] callback, that accepts resolved value or exception reason.
   * @returns {wConsequence}
   * @see {@link wConsequence~Correspondent} correspondent callback
   * @throws {Error} if passed more than one argument.
   * @method got
   * @memberof wConsequence#
   */

var got = function got( correspondent )
{
  var self = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( arguments.length === 0 )
  {
    correspondent = function(){};
  }

  return self._correspondentAppend
  ({
    correspondent : correspondent,
    context : arguments[ 1 ],
    argument : arguments[ 2 ],
    thenning : false,
  });

}

//

  /**
   * Works like got() method, but adds correspondent to queue only if function with same id not exist in queue yet.
   * Note: this is experimental tool.
   * @example
   *

     function gotHandler1( error, value )
     {
       console.log( 'handler 1: ' + value );
     };

     function gotHandler2( error, value )
     {
       console.log( 'handler 2: ' + value );
     };

     var con1 = new wConsequence();

     con1.gotOnce( gotHandler1 ).gotOnce( gotHandler1 ).gotOnce( gotHandler2 );
     con1.give( 'foo' ).give( 'bar' );

     // logs:
     // handler 1: foo
     // handler 2: bar
     // correspondent gotHandler1 has ben invoked only once, because second correspondent was not added to correspondents queue.

     // but:

     var con2 = new wConsequence();

     con2.give( 'foo' ).give( 'bar' ).give('baz');
     con2.gotOnce( gotHandler1 ).gotOnce( gotHandler1 ).gotOnce( gotHandler2 );

     // logs:
     // handler 1: foo
     // handler 1: bar
     // handler 2: baz
     // in this case first gotHandler1 has been removed from correspondents queue immediately after the invocation, so adding
     // second gotHandler1 is legitimate.

   *
   * @param {wConsequence~Correspondent|wConsequence} correspondent callback, that accepts resolved value or exception reason.
   * @returns {wConsequence}
   * @throws {Error} if passed more than one argument.
   * @throws {Error} if correspondent.id is not string.
   * @see {@link wConsequence~Correspondent} correspondent callback
   * @see {@link wConsequence#got} got method
   * @method gotOnce
   * @memberof wConsequence#
   */

var gotOnce = function gotOnce( correspondent )
{
  var self = this;
  var key = correspondent.id || correspondent.name;

  _.assert( _.strIsNotEmpty( key ) );
  _.assert( arguments.length === 1 );

  var i = _.arrayLeftIndexOf( self._correspondent,key,function( a )
  {
    return a.id || correspondent.name;
  });

  if( i >= 0 )
  return self;

  return self._correspondentAppend
  ({
    correspondent : correspondent,
    context : arguments[ 1 ],
    argument : arguments[ 2 ],
    thenning : false,
  });
}

//

  /**
   * Method accepts handler for resolved value/error. This handler method thenDo adds to wConsequence correspondents sequence.
      After processing accepted value, correspondent return value will be pass to the next handler in correspondents queue.
      Returns current wConsequence instance.

   * @example
     function gotHandler1( error, value )
     {
       console.log( 'handler 1: ' + value );
       value++;
       return value;
     };

     function gotHandler3( error, value )
     {
       console.log( 'handler 3: ' + value );
     };

     var con1 = new wConsequence();

     con1.thenDo( gotHandler1 ).thenDo( gotHandler1 ).got(gotHandler3);
     con1.give( 4 ).give( 10 );

     // prints:
     // handler 1: 4
     // handler 1: 5
     // handler 3: 6

   * @param {wConsequence~Correspondent|wConsequence} correspondent callback, that accepts resolved value or exception reason.
   * @returns {wConsequence}
   * @throws {Error} if missed correspondent.
   * @throws {Error} if passed more than one argument.
   * @see {@link wConsequence~Correspondent} correspondent callback
   * @see {@link wConsequence#got} got method
   * @method thenDo
   * @memberof wConsequence#
   */

var thenDo = function thenDo( correspondent )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.assert( self instanceof Self )

  return self._correspondentAppend
  ({
    correspondent : correspondent,
    context : arguments[ 1 ],
    argument : arguments[ 2 ],
    thenning : true,
  });

}

//

  /**
   * Adds to the wConsequences corespondents queue `correspondent` with sealed `context` and `args`. The result of
   * correspondent will be added to wConsequence message sequence after handling.
   * Returns current wConsequence instance.
   * @param {Object} context context that seals for correspondent callback
   * @param {Function} correspondent callback
   * @param {Array<*>} [args] arguments arguments that seals for correspondent callback
   * @returns {wConsequence}
   * @method thenSealed
   * @memberof wConsequence#
   */

// var thenSealed = function thenSealed( context,correspondent,args )
// {
//   var self = this;
//
//   _.assert( arguments.length === 2 || arguments.length === 3 );
//
//   if( arguments.length === 2 )
//   if( _.arrayLike( arguments[ 1 ] ) )
//   {
//     args = arguments[ 1 ];
//     correspondent = arguments[ 0 ];
//     context = undefined;
//   }
//
//   var correspondentJoined = _.routineSeal( context,correspondent,args );
//
//   debugger;
//   return self._correspondentAppend
//   ({
//     correspondent : correspondentJoined,
//     ifNoError : true,
//     thenning : true,
//   });
//
// }

//

  /**
   * Creates and adds to corespondents sequence error handler. If handled message contains error, corespondent logs it.
   * @returns {wConsequence}
   * @throws {Error} If called with any argument.
   * @method thenReportError
   * @memberof wConsequence#
   */

var thenReportError = function thenReportError( context,correspondent,args )
{
  var self = this;

  _.assert( arguments.length === 0 );

  var correspondent = function reportError( err )
  {
    throw _.errLog( err );
  }

  return self._correspondentAppend
  ({
    correspondent : correspondent,
    ifError : true,
    thenning : true,
  });

}

//

  /**
   * Works like thenDo() method, but adds correspondent to queue only if function with same id not exist in queue yet.
   * Note: this is an experimental tool.
   *
   * @example
     function gotHandler1( error, value )
     {
       console.log( 'handler 1: ' + value );
       value++;
       return value;
     };

     function gotHandler2( error, value )
     {
       console.log( 'handler 2: ' + value );
     };

     function gotHandler3( error, value )
     {
       console.log( 'handler 3: ' + value );
     };

     var con1 = new wConsequence();

     con1.thenOnce( gotHandler1 ).thenOnce( gotHandler1 ).got(gotHandler3);
     con1.give( 4 ).give( 10 );

     // prints
     // handler 1: 4
     // handler 3: 5

   * @param {wConsequence~Correspondent|wConsequence} correspondent callback, that accepts resolved value or exception
     reason.
   * @returns {*}
   * @throws {Error} if passed more than one argument.
   * @throws {Error} if correspondent is defined as anonymous function including anonymous function expression.
   * @see {@link wConsequence~Correspondent} correspondent callback
   * @see {@link wConsequence#thenDo} thenDo method
   * @see {@link wConsequence#gotOnce} gotOnce method
   * @method thenOnce
   * @memberof wConsequence#
   */

var thenOnce = function thenOnce( correspondent )
{
  var self = this;
  var key = correspondent.id;

  _.assert( _.strIsNotEmpty( key ) );
  _.assert( arguments.length === 1 );

  var i = _.arrayLeftIndexOf( self._correspondent,key,function( a )
  {
    return a.id;
  });

  if( i >= 0 )
  {
    debugger;
    return self;
  }

  return self._correspondentAppend
  ({
    correspondent : correspondent,
    context : arguments[ 1 ],
    argument : arguments[ 2 ],
    thenning : true,
  });
}

//

  /**
   * Returns new wConsequence instance. If on cloning moment current wConsequence has unhandled resolved values in queue
     the first of them would be handled by new wConsequence. Else pass accepted
   * @example
     function gotHandler1( error, value )
     {
       console.log( 'handler 1: ' + value );
       value++;
       return value;
     };

     function gotHandler2( error, value )
     {
       console.log( 'handler 2: ' + value );
     };

     var con1 = new wConsequence();
     con1.give(1).give(2).give(3);
     var con2 = con1.thenSplit();
     con2.got( gotHandler2 );
     con2.got( gotHandler2 );
     con1.got( gotHandler1 );
     con1.got( gotHandler1 );

      // prints:
      // handler 2: 1 // only first value copied into cloned wConsequence
      // handler 1: 1
      // handler 1: 2

   * @returns {wConsequence}
   * @throws {Error} if passed any argument.
   * @method thenSplit
   * @memberof wConsequence#
   */

var thenSplit = function thenSplit( first )
{
  var self = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  var result = new wConsequence();

  if( first )
  {
    result.thenDo( first );
    self.got( function( err,data )
    {
      this.give( err,data );
      result.give( err,data );
    });
  }
  else
  {
    self.thenDo( result );
  }

  return result;
}

//

  /**
   * Works like got() method, but value that accepts correspondent, passes to the next taker in takers queue without
     modification.
   * @example
   *
     function gotHandler1( error, value )
     {
       console.log( 'handler 1: ' + value );
       value++;
       return value;
     }

     function gotHandler2( error, value )
     {
       console.log( 'handler 2: ' + value );
     }

     function gotHandler3( error, value )
     {
       console.log( 'handler 3: ' + value );
     }

     var con1 = new wConsequence();
     con1.give(1).give(4);

     // prints:
     // handler 1: 1
     // handler 2: 1
     // handler 3: 4

   * @param {wConsequence~Correspondent|wConsequence} correspondent callback, that accepts resolved value or exception
     reason.
   * @returns {wConsequence}
   * @throws {Error} if passed more than one arguments
   * @see {@link wConsequence#got} got method
   * @method tap
   * @memberof wConsequence#
   */

var tap = function tap( correspondent )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.assert( self instanceof Self )

  return self._correspondentAppend
  ({
    correspondent : correspondent,
    context : undefined,
    argument : arguments[ 2 ],
    thenning : true,
    tapping : true,
  });

}

//

/**
 * ifErrorThen method pushed `correspondent` callback into wConsequence correspondents queue. That callback will
   trigger only in that case if accepted error parameter will be defined and not null. Else accepted parameters will
   be passed to the next correspondent in queue.
 * @example
 *
   function gotHandler1( error, value )
   {
     console.log( 'handler 1: ' + value );
     value++;
     return value;
   }

   function gotHandler3( error, value )
   {
     console.log( 'handler 3 err: ' + error );
     console.log( 'handler 3 val: ' + value );
   }

   var con2 = new wConsequence();

   con2._giveWithError( 'error msg', 8 ).give( 14 );
   con2.ifErrorThen( gotHandler3 ).got( gotHandler1 );

   // prints:
   // handler 3 err: error msg
   // handler 3 val: 8
   // handler 1: 14

 * @param {wConsequence~Correspondent|wConsequence} correspondent callback, that accepts exception  reason and value .
 * @returns {wConsequence}
 * @throws {Error} if passed more than one arguments
 * @see {@link wConsequence#got} thenDo method
 * @method ifErrorThen
 * @memberof wConsequence#
 */

var ifErrorThen = function ifErrorThen()
{

  _.assert( arguments.length === 1 );
  _.assert( this instanceof Self );

  return this._correspondentAppend
  ({
    correspondent : arguments[ 0 ],
    context : arguments[ 1 ],
    argument : arguments[ 2 ],
    thenning : true,
    ifError : true,
  });

}

//

var ifErrorGot = function ifErrorGot()
{

  _.assert( arguments.length === 1 );
  _.assert( this instanceof Self );

  return this._correspondentAppend
  ({
    correspondent : arguments[ 0 ],
    context : arguments[ 1 ],
    argument : arguments[ 2 ],
    thenning : false,
    ifError : true,
  });

}

//

/**
 * Method pushed `correspondent` callback into wConsequence correspondents queue. That callback will
   trigger only in that case if accepted error parameter will be null. Else accepted error will be passed to the next
   correspondent in queue. After handling accepted value, correspondent pass result to the next handler, like thenDo
   method.
 * @returns {wConsequence}
 * @throws {Error} if passed more than one arguments
 * @see {@link wConsequence#got} thenDo method
 * @method ifNoErrorThen
 * @memberof wConsequence#
 */

var ifNoErrorThen = function ifNoErrorThen()
{

  _.assert( arguments.length === 1 );
  _.assert( this instanceof Self )
  _.assert( arguments.length <= 3 );

  return this._correspondentAppend
  ({
    correspondent : arguments[ 0 ],
    context : arguments[ 1 ],
    argument : arguments[ 2 ],
    thenning : true,
    ifNoError : true,
  });

}

//

var ifNoErrorGot = function ifNoErrorGot()
{

  _.assert( arguments.length === 1 );
  _.assert( this instanceof Self )
  _.assert( arguments.length <= 3 );

  return this._correspondentAppend
  ({
    correspondent : arguments[ 0 ],
    context : arguments[ 1 ],
    argument : arguments[ 2 ],
    thenning : false,
    ifNoError : true,
  });

}

//

  /**
   * Using for debugging. Taps into wConsequence correspondents sequence predefined wConsequence correspondent callback, that contains
      'debugger' statement. If correspondent accepts non null `err` parameter, it generate and throw error based on
      `err` value. Else passed accepted `value` parameter to the next handler in correspondents sequence.
   * Note: this is experimental tool.
   * @returns {wConsequence}
   * @throws {Error} If try to call method with any argument.
   * @method thenDebug
   * @memberof wConsequence#
   */

var thenDebug = function thenDebug()
{
  var self = this;

  _.assert( arguments.length === 0 );

  return self._correspondentAppend
  ({
    correspondent : _onDebug,
    thenning : true,
  });

}

//

  /**
   * Works like thenDo, but when correspondent accepts message from messages sequence, execution of correspondent will be
      delayed. The result of correspondent execution will be passed to the handler that is first in correspondent queue
      on execution end moment.

   * @example
   *
     function gotHandler1( error, value )
     {
       console.log( 'handler 1: ' + value );
       value++;
       return value;
     }

     function gotHandler2( error, value )
     {
       console.log( 'handler 2: ' + value );
     }

     var con = new wConsequence();

     con.thenTimeOut(500, gotHandler1).got( gotHandler2 );
     con.give(90);
     //  prints:
     // handler 1: 90
     // handler 2: 91

   * @param {number} time delay in milliseconds
   * @param {wConsequence~Correspondent|wConsequence} correspondent callback, that accepts exception reason and value.
   * @returns {wConsequence}
   * @throws {Error} if missed arguments.
   * @throws {Error} if passed extra arguments.
   * @see {@link wConsequence~thenDo} thenDo method
   * @method thenTimeOut
   * @memberof wConsequence#
   */

var thenTimeOut = function thenTimeOut( time,correspondent )
{
  var self = this;

  _.assert( arguments.length === 1 || arguments.length === 2 );
  //_.assert( arguments.length === 1 || _.routineIs( correspondent ),'not implemented' );

  /**/

  if( !correspondent )
  correspondent = Self.passThru;

  /**/

  var _correspondent;
  if( _.routineIs( correspondent ) )
  _correspondent = function __thenTimeOut( err,data )
  {
    return _.timeOut( time,self,correspondent,[ err,data ] );
  }
  else
  _correspondent = function __thenTimeOut( err,data )
  {
    return _.timeOut( time,function()
    {
      correspondent.__giveWithError( err,data );
      if( err )
      throw _.err( err );
      return data;
    });
  }

  /**/

  return self._correspondentAppend
  ({
    correspondent : _correspondent,
    context : arguments[ 1 ],
    argument : arguments[ 2 ],
    thenning : true,
    /*debug : true,*/
  });

}

//

  /**
   * Correspondents added by persist method, will be accepted every messages resolved by wConsequence, like an event
      listener. Returns current wConsequence instance.
   * @example
     function gotHandler1( error, value )
     {
       console.log( 'message handler 1: ' + value );
       value++;
       return value;
     }

     function gotHandler2( error, value )
     {
       console.log( 'message handler 2: ' + value );
     }

     var con = new wConsequence();

     var messages = [ 'hello', 'world', 'foo', 'bar', 'baz' ],
     len = messages.length,
     i = 0;

     con.persist( gotHandler1).persist( gotHandler2 );

     for( ; i < len; i++) con.give( messages[i] );

     // prints:
     // message handler 1: hello
     // message handler 2: hello
     // message handler 1: world
     // message handler 2: world
     // message handler 1: foo
     // message handler 2: foo
     // message handler 1: bar
     // message handler 2: bar
     // message handler 1: baz
     // message handler 2: baz

   * @param {wConsequence~Correspondent|wConsequence} correspondent callback, that accepts exception reason and value.
   * @returns {wConsequence}
   * @throws {Error} if missed arguments.
   * @throws {Error} if passed extra arguments.
   * @see {@link wConsequence~got} got method
   * @method persist
   * @memberof wConsequence#
   */


var persist = function persist( correspondent )
{
  var self = this;

  _.assert( arguments.length === 1 );

  return self._correspondentAppend
  ({
    correspondent : correspondent,
    thenning : false,
    persistent : true,
  });

}

// --
// advanced
// --

  /**
   * Method accepts array of wConsequences object. If current wConsequence instance ready to resolve message, it will be
     wait for all passed wConsequence instances will been resolved, then current wConsequence resolve own message.
     Returns current wConsequence.
   * @example
   *
     function handleGot1(err, val)
     {
       if( err )
       {
         console.log( 'handleGot1 error: ' + err );
       }
       else
       {
         console.log( 'handleGot1 value: ' + val );
       }
     };

     var con1 = new wConsequence();
     var con2 = new wConsequence();

     con1.got( function( err, value )
     {
       console.log( 'con1 handler executed with value: ' + value + 'and error: ' + err );
     } );

     con2.got( function( err, value )
     {
       console.log( 'con2 handler executed with value: ' + value + 'and error: ' + err );
     } );

     var conOwner = new  wConsequence();

     conOwner.and( [ con1, con2 ] );

     conOwner.give( 100 );
     conOwner.got( handleGot1 );

     con1.give( 'value1' );
     con2.error( 'ups' );
     // prints
     // con1 handler executed with value: value1and error: null
     // con2 handler executed with value: undefinedand error: ups
     // handleGot1 value: 100

   * @param {wConsequence[]|wConsequence} srcs array of wConsequence
   * @returns {wConsequence}
   * @throws {Error} if missed arguments.
   * @throws {Error} if passed extra arguments.
   * @method andGet
   * @memberof wConsequence#
   */

var andGet = function andGet( srcs )
{
  var self = this;
  _.assert( arguments.length === 1 );
  return self._and( srcs,false );
}

//

  /**
   * Works like andGet() method, but unlike andGet() and() give back massages to src consequences once all come.
   * @see wConsequence#andGet
   * @param {wConsequence[]|wConsequence} srcs Array of wConsequence objects
   * @throws {Error} If missed or passed extra argument.
   * @method and
   * @memberof wConsequence#
   */

var and = function and( srcs )
{
  var self = this;
  _.assert( arguments.length === 1 );
  return self._and( srcs,true );
}

//

/**

  possible scenarios for "and" :

1. do not give back messages to src consequences( andGet )
2. give back massages to src consequences immediately
3. give back massages to src consequences once all come( and )

*/

var _and = function _and( srcs,thenning )
{
  var self = this;
  var anyErr;
  var returned = [];

  if( !_.arrayIs( srcs ) )
  srcs = [ srcs ];

  /* */

  function give()
  {

    if( thenning )
    for( var i = 0 ; i < srcs.length ; i++ )
    if( srcs[ i ] )
    srcs[ i ].give( returned[ i ][ 0 ],returned[ i ][ 1 ] );

    if( anyErr )
    self.error( anyErr );
    else
    self.give( null,returned[ srcs.length ][ 1 ] );

  }

  /* */

  var count = srcs.length+1;
  function collect( index,err,data )
  {
    count -= 1;
    if( err && !anyErr )
    anyErr = err;

    returned[ index ] = [ err,data ];

    if( count === 0 )
    setTimeout( give,0 );

  }

  /* */

  self.got( _.routineJoin( undefined,collect,[ srcs.length ] ) );

  /**/

  for( var a = 0 ; a < srcs.length ; a++ )
  {
    var src = srcs[ a ];
    _.assert( _.consequenceIs( src ) || src === null );
    if( src === null )
    {
      collect( a,null,null );
      continue;
    }
    src.got( _.routineJoin( undefined,collect,[ a ] ) );
  }

  return self;
}

//

/**
 * If type of `src` is function, the first method run it on begin, and if the result of `src` invocation is instance of
   wConsequence, the current wConsequence will be wait for it resolving, else method added result to messages sequence
   of the current instance.
 * If `src` is instance of wConsequence, the current wConsequence delegates to it his first corespondent.
 * Returns current wConsequence instance.
 * @example
 * function handleGot1(err, val)
   {
     if( err )
     {
       console.log( 'handleGot1 error: ' + err );
     }
     else
     {
       console.log( 'handleGot1 value: ' + val );
     }
   };

   var con = new  wConsequence();

   con.first( function() {
     return 'foo';
   } );

 con.give( 100 );
 con.got( handleGot1 );
 // prints: handleGot1 value: foo
*
  function handleGot1(err, val)
  {
    if( err )
    {
      console.log( 'handleGot1 error: ' + err );
    }
    else
    {
      console.log( 'handleGot1 value: ' + val );
    }
  };

  var con = new  wConsequence();

  con.first( function() {
    return wConsequence().give(3);
  } );

 con.give(100);
 con.got( handleGot1 );
 * @param {wConsequence|Function} src wConsequence or routine.
 * @returns {wConsequence}
 * @throws {Error} if `src` has unexpected type.
 * @method first
 * @memberof wConsequence#
 */

var first = function first( src )
{
  var self = this;

  _.assert( arguments.length === 1 );

  if( src instanceof wConsequence )
  {
    src.thenDo( self );
    src.give();
  }
  else if( _.routineIs( src ) )
  {
    var result;

    try
    {
      result = src();
    }
    catch( err )
    {
      result = self._handleError( err );
    }

    if( result instanceof wConsequence )
    result.thenDo( self );
    else
    self.give( result );
  }
  else throw _.err( 'unexpected' );

  return self;
}

//

var seal = function seal( context,method )
{
  var self = this;
  var result = {};

  /**/

  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assert( this instanceof Self )

  result.consequence = self;

  result.ifNoErrorThen = function ifNoErrorThen( _method )
  {
    var args = method ? arguments : arguments[ 1 ];
    var c = _.routineSeal( context,method || _method,args );
    self.ifNoErrorThen( c );
    return this;
  }

  result.ifErrorThen = function ifErrorThen( _method )
  {
    var args = method ? arguments : arguments[ 1 ];
    var c = _.routineSeal( context,method || _method,args );
    self.ifErrorThen( c );
    return this;
  }

  result.thenDo = function thenDo( _method )
  {
    var args = method ? arguments : arguments[ 1 ];
    var c = _.routineSeal( context,method || _method,args );
    self.thenDo( c );
    return this;
  }

  result.got = function got( _method )
  {
    var args = method ? arguments : arguments[ 2 ];
    var c = _.routineSeal( context,method || _method,args );
    self.got( c );
    return this;
  }

  return result;
}

// --
// messanger
// --

/**
 * Method pushes `message` into wConsequence messages queue.
 * Method also can accept two parameters: error, and
 * Returns current wConsequence instance.
 * @example
 * function gotHandler1( error, value )
   {
     console.log( 'handler 1: ' + value );
   };

   var con1 = new wConsequence();

   con1.got( gotHandler1 );
   con1.give( 'hello' );

   // prints " handler 1: hello ",
 * @param {*} [message] Resolved value
 * @returns {wConsequence} consequence current wConsequence instance.
 * @throws {Error} if passed extra parameters.
 * @method give
 * @memberof wConsequence#
 */

var give = function give( message )
{
  var self = this;
  _.assert( arguments.length === 2 || arguments.length === 1 || arguments.length === 0, 'expects 0, 1 or 2 arguments, got ' + arguments.length );
  if( arguments.length === 2 )
  return self._giveWithError( arguments[ 0 ],arguments[ 1 ] );
  else
  return self._giveWithError( null,message );
}

//

/**
 * Using for adds to message queue error reason, that using for informing corespondent that will handle it, about
 * exception
 * @example
   function showResult(err, val)
   {
     if( err )
     {
       console.log( 'handleGot1 error: ' + err );
     }
     else
     {
       console.log( 'handleGot1 value: ' + val );
     }
   };

   var con = new  wConsequence();

   function divade( x, y )
   {
     var result;
     if( y!== 0 )
     {
       result = x / y;
       con.give(result);
     }
     else
     {
       con.error( 'divide by zero' );
     }
   }

   con.got( showResult );
   divade( 3, 0 );

   // prints: handleGot1 error: divide by zero
 * @param {*|Error} error error, or value that represent error reason
 * @throws {Error} if passed extra parameters.
 * @method error
 * @memberof wConsequence#
 */

var error = function error( error )
{
  var self = this;
  _.assert( arguments.length === 1 || arguments.length === 0 );
  if( arguments.length === 0  )
  error = _.err();
  return self.__giveWithError( error,undefined );
}

//

/**
 * Method creates and pushes message object into wConsequence messages sequence.
 * Returns current wConsequence instance.
 * @param {*} error Error value
 * @param {*} argument resolved value
 * @returns {_giveWithError}
 * @private
 * @throws {Error} if missed arguments or passed extra arguments
 * @method _giveWithError
 * @memberof wConsequence#
 */

var _giveWithError = function _giveWithError( error,argument )
{
  var self = this;

  _.assert( arguments.length === 2 );

  if( error )
  error = _.err( error );

  return self.__giveWithError( error,argument );
}

//

var __giveWithError = function __giveWithError( error,argument )
{
  var self = this;

  var message =
  {
    error : error,
    argument : argument,
  }

  if( argument instanceof Self )
  throw _.err( 'not tested' );

  self._message.push( message );
  self._handleGot();

  return self;
}

//

/**
 * Creates and pushes message object into wConsequence messages sequence, and trying to get and return result of
    handling this message by appropriate correspondent.
 * @example
   var con = new  wConsequence();

   function increment( err, value )
   {
     return ++value;
   };


   con.got( increment );
   var result = con.ping( undefined, 4 );
   console.log( result );
   // prints 5;
 * @param {*} error
 * @param {*} argument
 * @returns {*} result
 * @throws {Error} if missed arguments or passed extra arguments
 * @method ping
 * @memberof wConsequence#
 */

function ping( error,argument )
{
  var self = this;

  _.assert( arguments.length === 2 );

  var message =
  {
    error : error,
    argument : argument,
  }

  self._message.push( message );
  var result = self._handleGot();

  return result;
}

// --
// handling mechanism
// --

  /**
   * Creates and handles error object based on `err` parameter.
   * Returns new wConsequence instance with error in messages queue.
   * @param {*} err error value.
   * @returns {wConsequence}
   * @private
   * @method _handleError
   * @memberof wConsequence#
   */

var _handleError = function _handleError( err )
{
  var self = this;
  var err = _.err( err );

  if( !err.attentionGiven )
  {
    //err.attentionNeeded = 1;
    //debugger;
    Object.defineProperty( err, 'attentionNeeded',
    {
      enumerable : false,
      configurable : true,
      writable : true,
      value : 1,
    });
  }

  var result = new wConsequence().error( err );

  if( Config.debug && err.attentionNeeded )
  {
    debugger;
    logger.error( 'Consequence caught error, details come later' );

    _.timeOut( 1, function()
    {
      if( err.attentionNeeded )
      {
        logger.error( 'Uncaught error caught by Consequence :' );
        _.errLog( err );
      }
    });
  }

  return result;
}

//

/**
 * Method for processing corespondents and _message queue. Provides handling of resolved message values and errors by
    corespondents from correspondents value. Method takes first message from _message sequence and try to pass it to
    the first corespondent in corespondents sequence. Method returns the result of current corespondent execution.
    There are several cases of _handleGot behavior:
    - if corespondent is regular function:
      trying to pass messages error and argument values into corespondent and execute. If during execution exception
      occurred, it will be catch by _handleError method. If corespondent was not added by tap or persist method,
      _handleGot will remove message from head of queue.

      If corespondent was added by thenDo, thenOnce, ifErrorThen, or by other "thenable" method of wConsequence, then:

      1) if result of corespondents is ordinary value, then _handleGot method appends result of corespondent to the
      head of messages queue, and therefore pass it to the next handler in corespondents queue.
      2) if result of corespondents is instance of wConsequence, _handleGot will append current wConsequence instance
      to result instance corespondents sequence.

      After method try to handle next message in queue if exists.

    - if corespondent is instance of wConsequence:
      in that case _handleGot pass message into corespondent`s messages queue.

      If corespondent was added by tap, or one of thenDo, thenOnce, ifErrorThen, or by other "thenable" method of
      wConsequence then _handleGot try to pass current message to the next handler in corespondents sequence.

    - if in current wConsequence are present corespondents added by persist method, then _handleGot passes message to
      all of them, without removing them from sequence.

 * @returns {*}
 * @throws {Error} if on invocation moment the _message queue is empty.
 * @private
 * @method _handleGot
 * @memberof wConsequence#
 */

var _handleGot = function _handleGot()
{
  var self = this;
  var result;
  var spliced = 0;

  if( !self._correspondent.length && !self._correspondentPersistent.length )
  return;

  _.assert( self._message.length,'_handleGot : none message left' );
  var message = self._message[ 0 ];

  /* give message to correspondent consequence */

  function __giveToConsequence( correspondent,ordinary )
  {

    result = correspondent.onGot.__giveWithError( message.error,message.argument );

    if( ordinary )
    if( correspondent.thenning )
    if( self._message.length )
    {
      self._handleGot();
    }

  }

  /* give message to correspondent routine */

  function __giveToRoutine( correspondent,ordinary )
  {

    if( Config.debug )
    if( correspondent.debug )
    debugger;

    var execute = true;
    var execute = execute && ( !correspondent.ifError || ( correspondent.ifError && !!message.error ) );
    var execute = execute && ( !correspondent.ifNoError || ( correspondent.ifNoError && !message.error ) );

    if( !execute )
    return;

    var splice = true;
    splice = splice && !correspondent.tapping && ordinary;
    splice = splice && execute;

    if( splice )
    {
      spliced = 1;
      self._message.shift();
    }

    /**/

    try
    {
      if( correspondent.ifError )
      result = correspondent.onGot.call( self,message.error );
      else if( correspondent.ifNoError )
      result = correspondent.onGot.call( self,message.argument );
      else
      result = correspondent.onGot.call( self,message.error,message.argument );
    }
    catch( err )
    {
      result = self._handleError( err );
    }

    /**/

    if( correspondent.thenning )
    {
      if( result instanceof Self )
      result.thenDo( self );
      else
      self.give( result );
    }

  }

  /* give to */

  function __giveTo( correspondent,ordinary )
  {

    if( correspondent.onGot instanceof Self )
    {
      __giveToConsequence( correspondent,ordinary );
    }
    else
    {
      __giveToRoutine( correspondent,ordinary );
    }

  }

  /* ordinary */

  var correspondent;
  if( self._correspondent.length > 0 )
  {
    correspondent = self._correspondent.shift();
    __giveTo( correspondent,1 );
  }

  /* persistent */

  if( !correspondent || ( correspondent && !correspondent.tapping ) )
  {

    for( var i = 0 ; i < self._correspondentPersistent.length ; i++ )
    {
      var pTaker = self._correspondentPersistent[ i ];
      __giveTo( pTaker,0 );
    }

    if( !spliced && self._correspondentPersistent.length )
    self._message.shift();

  }

  /* next message */

  if( self._message.length )
  self._handleGot();

  return result;
}

// --
// correspondent
// --

  /**
   * The _corespondentMap object
   * @typedef {Object} _corespondentMap
   * @property {Function|wConsequence} onGot function or wConsequence instance, that accepts resolved messages from
   * messages queue.
   * @property {boolean} thenning determines if corespondent pass his result back into messages queue.
   * @property {boolean} tapping determines if corespondent return accepted message back into  messages queue.
   * @property {boolean} ifError turn on corespondent only if message represent error;
   * @property {boolean} ifNoError turn on corespondent only if message represent no error;
   * @property {boolean} debug enables debugging.
   * @property {string} id corespondent id.
   */

  /**
   * Returns array of corespondents
   * @example
   * function corespondent1(err, val)
     {
       console.log( 'corespondent1 value: ' + val );
     };

     function corespondent2(err, val)
     {
       console.log( 'corespondent2 value: ' + val );
     };

     function corespondent3(err, val)
     {
       console.log( 'corespondent1 value: ' + val );
     };

     var con = wConsequence();

     con.tap( corespondent1 ).thenDo( corespondent2 ).got( corespondent3 );

     var corespondents = con.correspondentsGet();

     console.log( corespondents );

     // prints
     // [ {
     //  onGot: [Function: corespondent1],
     //  thenning: true,
     //  tapping: true,
     //  ifError: false,
     //  ifNoError: false,
     //  debug: false,
     //  id: 'corespondent1' },
     // { onGot: [Function: corespondent2],
     //   thenning: true,
     //   tapping: false,
     //   ifError: false,
     //   ifNoError: false,
     //   debug: false,
     //   id: 'corespondent2' },
     // { onGot: [Function: corespondent3],
     //   thenning: false,
     //   tapping: false,
     //   ifError: false,
     //   ifNoError: false,
     //   debug: false,
     //   id: 'corespondent3'
     // } ]
   * @returns {_corespondentMap[]}
   * @method correspondentsGet
   * @memberof wConsequence
   */

function correspondentsGet()
{
  var self = this;
  return self._correspondent;
}

//

  /**
   * If called without arguments, method correspondentsCancel() removes all corespondents from wConsequence
   * correspondents queue.
   * If as argument passed routine, method correspondentsCancel() removes it from corespondents queue if exists.
   * @example
   function corespondent1(err, val)
   {
     console.log( 'corespondent1 value: ' + val );
   };

   function corespondent2(err, val)
   {
     console.log( 'corespondent2 value: ' + val );
   };

   function corespondent3(err, val)
   {
     console.log( 'corespondent1 value: ' + val );
   };

   var con = wConsequence();

   con.got( corespondent1 ).got( corespondent2 );
   con.correspondentsCancel();

   con.got( corespondent3 );
   con.give( 'bar' );

   // prints
   // corespondent1 value: bar
   * @param [correspondent]
   * @method correspondentsCancel
   * @memberof wConsequence
   */

var correspondentsCancel = function correspondentsCancel( correspondent )
{
  var self = this;

  _.assert( arguments.length === 0 || _.routineIs( correspondent ) );

  if( arguments.length === 0 )
  {
    self._correspondent.splice( 0,self._correspondent.length );
  }
  else
  {
    throw _.err( 'not tested' );
    _.arrayRemoveOnce( self._correspondent,correspondent );
  }

}

// --
// message
// --

/**
 * The internal wConsequence view of message.
 * @typedef {Object} _messageObject
 * @property {*} error error value
 * @property {*} argument resolved value
 */

/**
 * Returns messages queue.
 * @example
 * var con = wConsequence();

   con.give( 'foo' );
   con.give( 'bar ');
   con.error( 'baz' );


   var messages = con.messagesGet();

   console.log( messages );

   // prints
   // [ { error: null, argument: 'foo' },
   // { error: null, argument: 'bar ' },
   // { error: 'baz', argument: undefined } ]

 * @returns {_messageObject[]}
 * @method messagesGet
 * @memberof wConsequence
 */

var messagesGet = function messagesGet( index )
{
  var self = this;
  _.assert( arguments.length === 0 || arguments.length === 1 )
  _.assert( index === undefined || _.numberIs( index ) );
  if( index !== undefined )
  return self._message[ index ];
  else
  return self._message;
}

//

/**
 * If called without arguments, method removes all messages from wConsequence
 * correspondents queue.
 * If as argument passed value, method messagesCancel() removes it from messages queue if messages queue contains it.
 * @example
 * var con = wConsequence();

   con.give( 'foo' );
   con.give( 'bar ');
   con.error( 'baz' );

   con.messagesCancel();
   var messages = con.messagesGet();

   console.log( messages );
   // prints: []
 * @param {_messageObject} data message object for removing.
 * @throws {Error} If passed extra arguments.
 * @method correspondentsCancel
 * @memberof wConsequence
 */

var messagesCancel = function messagesCancel( data )
{
  var self = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( arguments.length === 0 )
  self._message.splice( 0,self._message.length );
  else
  {
    throw _.err( 'not tested' );
    _.arrayRemoveOnce( self._message,data );
  }

}

//

  /**
   * Returns number of messages in current messages queue.
   * @example
   * var con = wConsequence();

     var conLen = con.messageHas();
     console.log( conLen );

     con.give( 'foo' );
     con.give( 'bar' );
     con.error( 'baz' );
     conLen = con.messageHas();
     console.log( conLen );

     con.messagesCancel();

     conLen = con.messageHas();
     console.log( conLen );
     // prints: 0, 3, 0;

   * @returns {number}
   * @method messageHas
   * @memberof wConsequence
   */

function messageHas()
{
  var self = this;
  if( self._message.length <= self._correspondent.length )
  return 0;
  return self._message.length - self._correspondent.length;
}

// --
// etc
// --

  /**
   * Clears all messages and corespondents of wConsequence.
   * @method clear
   * @memberof wConsequence
   */

var clear = function clear( data )
{
  var self = this;
  _.assert( arguments.length === 0 );

  self.correspondentsCancel();
  self.messagesCancel();

}

//

  /**
   * Serializes current wConsequence instance.
   * @example
   * function corespondent1(err, val)
     {
       console.log( 'corespondent1 value: ' + val );
     };

     var con = wConsequence();
     con.got( corespondent1 );

     var conStr = con.toStr();

     console.log( conStr );

     con.give( 'foo' );
     con.give( 'bar' );
     con.error( 'baz' );

     conStr = con.toStr();

     console.log( conStr );
     // prints:

     // wConsequence( 0 )
     // message : 0
     // correspondents : 1
     // correspondent names : corespondent1

     // corespondent1 value: foo

     // wConsequence( 0 )
     // message : 2
     // correspondents : 0
     // correspondent names :

   * @returns {string}
   * @method toStr
   * @memberof wConsequence
   */

function toStr()
{
  var self = this;
  var result = self.nickName;

  var names = _.entitySelect( self.correspondentsGet(),'*.id' );

  result += '\n  message : ' + self.messagesGet().length;
  result += '\n  correspondents : ' + self.correspondentsGet().length;
  result += '\n  correspondent names : ' + names.join( ' ' );

  return result;
}

//

/**
 * Can use as correspondent. If `err` is not null, throws exception based on `err`. Returns `data`.
 * @callback wConsequence._onDebug
 * @param {*} err Error object, or any other type, that represent or describe an error reason. If during resolving
 value no exception occurred, it will be set to null;
 * @param {*} data resolved by wConsequence value;
 * @returns {*}
 * @memberof wConsequence
 */

function _onDebug( err,data )
{
  debugger;
  if( err )
  throw _.err( err );
  return data;
}

// --
// static
// --

var from_static = function from_static( src )
{

  _.assert( arguments.length === 1 );

  if( src instanceof Self )
  return src;

  if( _.errorIs( src ) )
  return new wConsequence().error( src );
  else
  return new wConsequence().give( src );

}

//

/**
 * If `consequence` if instance of wConsequence, method pass arg and error if defined to it's message sequence.
 * If `consequence` is routine, method pass arg as arguments to it and return result.
 * @example
 * function showResult(err, val)
   {
     if( err )
     {
       console.log( 'handleGot1 error: ' + err );
     }
     else
     {
       console.log( 'handleGot1 value: ' + val );
     }
   };

   var con = new  wConsequence();

   con.got( showResult );

   wConsequence.give( con, 'hello world' );
   // prints: handleGot1 value: hello world
 * @param {Function|wConsequence} consequence
 * @param {*} arg argument value
 * @param {*} [error] error value
 * @returns {*}
 * @static
 * @method give
 * @memberof wConsequence
 */

var give_static = function give_static( consequence )
{

  _.assert( arguments.length === 2 || arguments.length === 3 );

  var err,got;
  if( arguments.length === 2 )
  {
    got = arguments[ 1 ];
  }
  else if( arguments.length === 3 )
  {
    err = arguments[ 1 ];
    got = arguments[ 2 ];
  }

  var args = [ got ];

  return _give_static
  ({
    consequence : consequence,
    context : undefined,
    error : err,
    args : args,
  });

}

//

  /**
   * If `o.consequence` is instance of wConsequence, method pass o.args and o.error if defined, to it's message sequence.
   * If `o.consequence` is routine, method pass o.args as arguments to it and return result.
   * @param {Object} o parameters object.
   * @param {Function|wConsequence} o.consequence wConsequence or routine.
   * @param {Array} o.args values for wConsequence messages queue or arguments for routine.
   * @param {*|Error} o.error error value.
   * @returns {*}
   * @private
   * @throws {Error} if missed arguments.
   * @throws {Error} if passed argument is not object.
   * @throws {Error} if o.consequence has unexpected type.
   * @method _give_static
   * @memberof wConsequence
   */

var _give_static = function _give_static( o )
{
  var context;

  if( !( _.arrayIs( o.args ) && o.args.length <= 1 ) )
  debugger;

  _.assert( arguments.length === 1 );
  _.assert( _.objectIs( o ) );
  _.assert( _.arrayIs( o.args ) && o.args.length <= 1, 'not tested' );

  /**/

  if( _.arrayIs( o.consequence ) )
  {

    for( var i = 0 ; i < o.consequence.length ; i++ )
    {
      var optionsGive = _.mapExtend( {},o );
      optionsGive.consequence = o.consequence[ i ];
      _give_static( optionsGive );
    }

  }
  else if( o.consequence instanceof Self )
  {

    _.assert( _.arrayIs( o.args ) && o.args.length <= 1 );

    context = o.consequence;

    if( o.error !== undefined )
    {
      o.consequence.__giveWithError( o.error,o.args[ 0 ] );
    }
    else
    {
      o.consequence.give( o.args[ 0 ] );
    }

  }
  else if( _.routineIs( o.consequence ) )
  {

    _.assert( _.arrayIs( o.args ) && o.args.length <= 1 );

    if( o.error !== undefined )
    {
      return o.consequence.call( context,o.error,o.args[ 0 ] );
    }
    else
    {
      return o.consequence.call( context,null,o.args[ 0 ] );
    }

  }
  else throw _.err( 'Unknown type of consequence : ' + _.strTypeOf( o.consequence ) );

}

//

  /**
   * If `consequence` if instance of wConsequence, method error to it's message sequence.
   * If `consequence` is routine, method pass error as arguments to it and return result.
   * @example
   * function showResult(err, val)
     {
       if( err )
       {
         console.log( 'handleGot1 error: ' + err );
       }
       else
       {
         console.log( 'handleGot1 value: ' + val );
       }
     };

     var con = new  wConsequence();

     con.got( showResult );

     wConsequence.error( con, 'something wrong' );
   // prints: handleGot1 error: something wrong
   * @param {Function|wConsequence} consequence
   * @param {*} error error value
   * @returns {*}
   * @static
   * @method error
   * @memberof wConsequence
   */

function error_static( consequence,error )
{

  _.assert( arguments.length === 2 );

  return _give_static
  ({
    consequence : consequence,
    context : undefined,
    error : error,
    args : [],
  });

}

//

  /**
   * Works like [give]{@link wConsequence.give} but accepts also context, that will be sealed to correspondent.
   * @see wConsequence.give
   * @param {Function|wConsequence} consequence wConsequence or routine.
   * @param {Object} context sealed context
   * @param {*} err error reason
   * @param {*} got arguments
   * @returns {*}
   * @method giveWithContextAndError
   * @memberof wConsequence
   */

var giveWithContextAndError_static = function giveWithContextAndError_static( consequence,context,err,got )
{

  if( err === undefined )
  err = null;

  console.warn( 'deprecated' );
  //debugger;

  var args = [ got ];
  if( arguments.length > 4 )
  args = _.arraySlice( arguments,3 );

  return _give_static
  ({
    consequence : consequence,
    context : context,
    error : err,
    args : args,
  });

}

//

/**
 * Method accepts correspondent callback. Returns special correspondent that wrap passed one. Passed corespondent will
 * be invoked only if handling message contains error value. Else given message will be delegate to the next handler
 * in wConsequence, to the which result correspondent was added.
 * @param {correspondent} errHandler handler for error
 * @returns {correspondent}
 * @static
 * @thorws If missed arguments or passed extra ones.
 * @method ifErrorThen
 * @memberof wConsequence
 * @see {@link wConsequence#ifErrorThen}
 */

function ifErrorThen_static()
{

  _.assert( arguments.length === 1 );
  _.assert( this === Self );

  var onEnd = arguments[ 0 ];
  _.assert( arguments.length === 1 );
  _.assert( _.routineIs( onEnd ) );

  return function ifErrorThen( err,data )
  {

    _.assert( arguments.length === 2 );

    if( err )
    {
      return onEnd( err,data );
    }
    else
    {
      return wConsequence().give( data );
    }

  }

}

//

  /**
   * Method accepts correspondent callback. Returns special correspondent that wrap passed one. Passed corespondent will
   * be invoked only if handling message does not contain error value. Else given message with error will be delegate to
   * the next handler in wConsequence, to the which result correspondent was added.
   * @param {correspondent} vallueHandler resolved message handler
   * @returns {corespondent}
   * @static
   * @throws {Error} If missed arguments or passed extra one;
   * @method ifNoErrorThen
   * @memberof wConsequence
   */

function ifNoErrorThen_static()
{

  _.assert( arguments.length === 1 );
  _.assert( this === Self );

  var onEnd = arguments[ 0 ];
  _.assert( arguments.length === 1 );
  _.assert( _.routineIs( onEnd ) );

  return function ifNoErrorThen( err,data )
  {

    _.assert( arguments.length === 2 );

    if( !err )
    {
      return onEnd( err,data );
    }
    else
    {
      return wConsequence().error( err );
    }

  }

}

//

  /**
   * Can use as correspondent. If `err` is not null, throws exception based on `err`. Returns `data`.
   * @callback wConsequence.passThru
   * @param {*} err Error object, or any other type, that represent or describe an error reason. If during resolving
   value no exception occurred, it will be set to null;
   * @param {*} data resolved by wConsequence value;
   * @returns {*}
   * @memberof wConsequence
   */

var passThru_static = function passThru( err,data )
{
  if( err )
  throw _.err( err );
  return data;
}

// --
// experimental
// --

var FunctionWithin = function FunctionWithin( consequence )
{
  var routine = this;
  var args;
  var context;

  _.assert( arguments.length === 1 );
  _.assert( consequence instanceof Self );

  consequence.thenDo( function( err,data )
  {

    return routine.apply( context,args );

  });

  return function()
  {
    context = this;
    args = arguments;
    return consequence;
  }

}

//

var FunctionThereafter = function FunctionThereafter()
{
  var con = new wConsequence();
  var routine = this;
  var args = arguments

  con.thenDo( function( err,data )
  {

    return routine.apply( null,args );

  });

  return con;
}

//

if( 0 )
{
  Function.prototype.within = FunctionWithin;
  Function.prototype.thereafter = FunctionThereafter;
}

//

function experimentThereafter()
{
  debugger;

  function f()
  {
    debugger;
    console.log( 'done2' );
  }

  _.timeOut( 5000,console.log.thereafter( 'done' ) );
  _.timeOut( 5000,f.thereafter() );

  debugger;

}

//

function experimentWithin()
{

  debugger;
  var con = _.timeOut( 30000 );
  console.log.within( con ).call( console,'done' );
  con.thenDo( function()
  {

    debugger;
    console.log( 'done2' );

  });

}

//

function experimentCall()
{

  var con = new wConsequence();
  con( 123 );
  con.thenDo( function( err,data )
  {

    console.log( 'got :',data );

  });

  debugger;

}

// --
// relationships
// --

var Composes =
{
  id : '',
  _correspondent : [],
  _correspondentPersistent : [],
  _message : [],
}

var Restricts =
{
}

var Statics =
{

  from : from_static,

  _give : _give_static,
  give : give_static,

  error : error_static,

  giveWithContextAndError : giveWithContextAndError_static,

  ifErrorThen : ifErrorThen_static,
  ifNoErrorThen : ifNoErrorThen_static,

  passThru : passThru_static,

}

// --
// proto
// --

var Extend =
{

  init : init,


  // mechanics

  _correspondentAppend : _correspondentAppend,


  // chainer

  got : got,
  done : got,
  gotOnce : gotOnce, /* experimental */

  thenDo : thenDo,
  // thenSealed : thenSealed,
  thenReportError : thenReportError, /* experimental */

  thenOnce : thenOnce, /* experimental */
  thenSplit : thenSplit,

  tap : tap,

  ifErrorThen : ifErrorThen,
  ifErrorGot : ifErrorGot,
  ifNoErrorThen : ifNoErrorThen,
  ifNoErrorGot : ifNoErrorGot,

  thenDebug : thenDebug, /* experimental */
  thenTimeOut : thenTimeOut,


  // persist chainer

  persist : persist, /* experimental */


  // advanced

  andGet : andGet,
  and : and,
  _and : _and,

  first : first,

  seal : seal,


  // messanger

  give : give,
  error : error,
  _giveWithError : _giveWithError,
  __giveWithError : __giveWithError,
  ping : ping, /* experimental */


  // handling mechanism

  _handleError : _handleError,
  _handleGot : _handleGot,


  // correspondent

  correspondentsGet : correspondentsGet,
  correspondentsCancel : correspondentsCancel,


  // message

  messagesGet : messagesGet,
  messagesCancel : messagesCancel,
  messageHas : messageHas,
  // hasMessage : messageHas,

  // etc

  clear : clear,
  toStr : toStr,
  _onDebug : _onDebug,


  // class var

  usingAsyncTaker : 0,


  // relationships

  constructor : Self,
  Composes : Composes,
  Restricts : Restricts,

}

//

var Supplement =
{
  Statics : Statics,
}

//

_.protoMake
({
  constructor : Self,
  parent : Parent,
  extend : Extend,
  supplement : Supplement,
});

_.assert( _.routineIs( Self.prototype.passThru ) );
_.assert( _.routineIs( Self.passThru ) );

//

if( _global_.wCopyable )
{
  wCopyable.mixin( Self );

  if( Config.debug )
  {
    // debugger;
    var con = new Self();
    var x3 = Self._SelfGet();

    var x1 = con.Self;
    var x2 = Self.prototype.Self;
    var x4 = Self.Self;
    // debugger;
    _.assert( x1 === x2 );
    _.assert( x1 === x3 );
    _.assert( x1 === x4 );
    // debugger;
  }

}

//

_.accessor
({
  object : Self.prototype,
  names :
  {
  }
});

//

_.accessorForbid( Self.prototype,
  {
    every : 'every',
    mutex : 'mutex',
    mode : 'mode',
  }
);

//

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

_global_[ Self.name ] = wTools.Consequence = Self;

return Self;

})();
