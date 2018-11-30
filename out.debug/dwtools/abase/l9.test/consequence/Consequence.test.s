( function _Consequence_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  var _ = require( '../../../Tools.s' );

  require( '../../l9/consequence/Consequence.s' );

  _.include( 'wTesting' );

}

var _global = _global_;
var _ = _global_.wTools;

// --
// test
// --

function simple( test )
{
  var self = this;

  test.case = 'class checks'; /* */

  test.is( _.routineIs( wConsequence.prototype.passThru ) );
  test.is( _.routineIs( wConsequence.passThru ) );
  test.is( _.objectIs( wConsequence.prototype.KindOfArguments ) );
  test.is( _.objectIs( wConsequence.KindOfArguments ) );
  test.is( wConsequence.name === 'wConsequence' );
  test.is( wConsequence.shortName === 'Consequence' );

  test.case = 'construction'; /* */

  var con1 = new _.Consequence().give( 1 );
  var con2 = _.Consequence().give( 2 );
  var con3 = con2.clone();

  test.identical( con1.resourcesGet().length,1 );
  test.identical( con2.resourcesGet().length,1 );
  test.identical( con3.resourcesGet().length,1 );

  test.case = 'class test'; /* */

  test.is( _.consequenceIs( con1 ) );
  test.is( con1 instanceof wConsequence );
  test.is( _.consequenceIs( con2 ) );
  test.is( con2 instanceof wConsequence );
  test.is( _.consequenceIs( con3 ) );
  test.is( con3 instanceof wConsequence );

  con3.give( 3 );
  con3( 4 );
  con3( 5 );

  con3.got( ( err,arg ) => test.identical( arg,2 ) );
  con3.got( ( err,arg ) => test.identical( arg,3 ) );
  con3.got( ( err,arg ) => test.identical( arg,4 ) );
  con3.doThen( ( err,arg ) => test.identical( con3.resourcesGet().length,0 ) );

  return con3;
}

//

function ordinarMessage( test )
{
  var c = this;
  var amode = _.Consequence.asyncModeGet();

  test.case = 'give single resource';

  var testCon = new _.Consequence().give( null )

   /* asyncTaking : 0, asyncGiving : 0 */

  .doThen( () => _.Consequence.asyncModeSet([ 0, 0 ]) )
  .doThen( function()
  {
    var con = new _.Consequence();
    con.give( 1 );
    test.identical( con.resourcesGet().length, 1 );
    con.got( function( err, got )
    {
      test.identical( err, undefined )
      test.identical( got, 1 );
    })
    test.identical( con.resourcesGet().length, 0 );
    test.identical( con.competitorsEarlyGet().length, 0 );
    return null;
  })

  /* asyncTaking : 1, asyncGiving : 0 */

  .doThen( () => _.Consequence.asyncModeSet([ 1, 0 ]) )
  .doThen( function()
  {
    var con = new _.Consequence();
    con.give( 1 );
    test.identical( con.resourcesGet().length, 1 );
    con.got( function( err, got )
    {
      test.identical( err, undefined )
      test.identical( got, 1 );
    })
    test.identical( con.resourcesGet().length, 1 );
    test.identical( con.competitorsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /* asyncTaking : 0, asyncGiving : 1 */

  .doThen( () => _.Consequence.asyncModeSet([ 0, 1 ]) )
  .doThen( function()
  {
    var con = new _.Consequence();
    con.give( 1 );

    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 1 );
      test.identical( con.competitorsEarlyGet().length, 0 );

      con.got( function( err, got )
      {
        test.identical( err, undefined )
        test.identical( got, 1 );
      })
      return null;
    })
    .doThen( function()
    {
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /* asyncTaking : 1, asyncGiving : 1 */

  .doThen( () => _.Consequence.asyncModeSet([ 1, 1 ]) )
  .doThen( function()
  {
    var con = new _.Consequence();
    con.give( 1 );
    con.got( function( err, got )
    {
      test.identical( err, undefined )
      test.identical( got, 1 );
    })
    test.identical( con.resourcesGet().length, 1 );
    test.identical( con.competitorsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      return null;
    })
  });

  test.case = 'give several resources';

  /* asyncTaking : 0, asyncGiving : 0 */

  testCon.doThen( () => _.Consequence.asyncModeSet([ 0, 0 ]) )
  .doThen( function()
  {
    var con = new _.Consequence();
    con.give( 1 ).give( 2 ).give( 3 );
    test.identical( con.resourcesGet().length, 3 );
    con.got( ( err, got ) => test.identical( got, 1 ) );
    con.got( ( err, got ) => test.identical( got, 2 ) );
    con.got( ( err, got ) => test.identical( got, 3 ) );
    test.identical( con.competitorsEarlyGet().length, 0 );
    test.identical( con.resourcesGet().length, 0 );
    return null;
  })

  /* asyncTaking : 1, asyncGiving : 0 */

  testCon.doThen( () => _.Consequence.asyncModeSet([ 1, 0 ]) )
  .doThen( function()
  {
    var con = new _.Consequence();
    con.give( 1 ).give( 2 ).give( 3 );
    con.got( ( err, got ) => test.identical( got, 1 ) );
    con.got( ( err, got ) => test.identical( got, 2 ) );
    con.got( ( err, got ) => test.identical( got, 3 ) );
    test.identical( con.competitorsEarlyGet().length, 3 );
    test.identical( con.resourcesGet().length, 3 );
    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /* asyncTaking : 0, asyncGiving : 1 */

  testCon.doThen( () => _.Consequence.asyncModeSet([ 0, 1 ]) )
  .doThen( function()
  {
    var con = new _.Consequence();
    con.give( 1 ).give( 2 ).give( 3 );

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 3 );

      con.got( ( err, got ) => test.identical( got, 1 ) );
      con.got( ( err, got ) => test.identical( got, 2 ) );
      con.got( ( err, got ) => test.identical( got, 3 ) );
      return null;
    })
    .doThen( function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })

  })

  /* asyncTaking : 1, asyncGiving : 1 */

  testCon.doThen( () => _.Consequence.asyncModeSet([ 1, 1 ]) )
  .doThen( function()
  {
    var con = new _.Consequence();
    con.give( 1 ).give( 2 ).give( 3 );
    con.got( ( err, got ) => test.identical( got, 1 ) );
    con.got( ( err, got ) => test.identical( got, 2 ) );
    con.got( ( err, got ) => test.identical( got, 3 ) );
    test.identical( con.competitorsEarlyGet().length, 3 );
    test.identical( con.resourcesGet().length, 3 );
    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  });

  test.case = 'give single error';

  /* asyncTaking : 0, asyncGiving : 0 */

  testCon.doThen( () => _.Consequence.asyncModeSet([ 0, 0 ]) )
  .doThen( function()
  {
    var con = new _.Consequence();
    con.error( 'err' );
    test.identical( con.resourcesGet().length, 1 );
    con.got( function( err, got )
    {
      test.identical( err, 'err' )
      test.identical( got, undefined );
    })
    test.identical( con.resourcesGet().length, 0 );
    test.identical( con.competitorsEarlyGet().length, 0 );
    return null;
  })

  /* asyncTaking : 1, asyncGiving : 0 */

  .doThen( () => _.Consequence.asyncModeSet([ 1, 0 ]) )
  .doThen( function()
  {
    var con = new _.Consequence();
    con.error( 'err' );
    test.identical( con.resourcesGet().length, 1 );
    con.got( function( err, got )
    {
      test.identical( err, 'err' )
      test.identical( got, undefined );
    })
    test.identical( con.resourcesGet().length, 1 );
    test.identical( con.competitorsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /* asyncTaking : 0, asyncGiving : 1 */

  .doThen( () => _.Consequence.asyncModeSet([ 0, 1 ]) )
  .doThen( function()
  {
    var con = new _.Consequence();
    con.error( 'err' );

    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 1 );
      test.identical( con.competitorsEarlyGet().length, 0 );

      con.got( function( err, got )
      {
        test.identical( err, 'err' )
        test.identical( got, undefined );
      })
      return null;
    })
    .doThen( function()
    {
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /* asyncTaking : 1, asyncGiving : 1 */

  .doThen( () => _.Consequence.asyncModeSet([ 1, 1 ]) )
  .doThen( function()
  {
    var con = new _.Consequence();
    con.error( 'err' );
    con.got( function( err, got )
    {
      test.identical( err, 'err' )
      test.identical( got, undefined );
    })
    test.identical( con.resourcesGet().length, 1 );
    test.identical( con.competitorsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      return null;
    })
  });

  test.case = 'give several error resources';

  /* asyncTaking : 0, asyncGiving : 0 */

  testCon.doThen( () => _.Consequence.asyncModeSet([ 0, 0 ]) )
  .doThen( function()
  {
    var con = new _.Consequence();
    con.error( 'err1' ).error( 'err2' ).error( 'err3' );
    test.identical( con.resourcesGet().length, 3 );
    con.got( ( err, got ) => test.identical( err, 'err1' ) );
    con.got( ( err, got ) => test.identical( err, 'err2' ) );
    con.got( ( err, got ) => test.identical( err, 'err3' ) );
    test.identical( con.competitorsEarlyGet().length, 0 );
    test.identical( con.resourcesGet().length, 0 );
    return null;
  })

  /* asyncTaking : 1, asyncGiving : 0 */

  testCon.doThen( () => _.Consequence.asyncModeSet([ 1, 0 ]) )
  .doThen( function()
  {
    var con = new _.Consequence();
    con.error( 'err1' ).error( 'err2' ).error( 'err3' );
    con.got( ( err, got ) => test.identical( err, 'err1' ) );
    con.got( ( err, got ) => test.identical( err, 'err2' ) );
    con.got( ( err, got ) => test.identical( err, 'err3' ) );
    test.identical( con.competitorsEarlyGet().length, 3 );
    test.identical( con.resourcesGet().length, 3 );
    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /* asyncTaking : 0, asyncGiving : 1 */

  testCon.doThen( () => _.Consequence.asyncModeSet([ 0, 1 ]) )
  .doThen( function()
  {
    var con = new _.Consequence();
    con.error( 'err1' ).error( 'err2' ).error( 'err3' );

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 3 );

      con.got( ( err, got ) => test.identical( err, 'err1' ) );
      con.got( ( err, got ) => test.identical( err, 'err2' ) );
      con.got( ( err, got ) => test.identical( err, 'err3' ) );
      return null;
    })
    .doThen( function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /* asyncTaking : 1, asyncGiving : 1 */

  testCon.doThen( () => _.Consequence.asyncModeSet([ 1, 1 ]) )
  .doThen( function()
  {
    var con = new _.Consequence();
    con.error( 'err1' ).error( 'err2' ).error( 'err3' );
    con.got( ( err, got ) => test.identical( err, 'err1' ) );
    con.got( ( err, got ) => test.identical( err, 'err2' ) );
    con.got( ( err, got ) => test.identical( err, 'err3' ) );
    test.identical( con.competitorsEarlyGet().length, 3 );
    test.identical( con.resourcesGet().length, 3 );
    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  });

  /* */

  testCon.doThen( () =>
  {
    _.Consequence.asyncModeSet( amode );
    return null;
  })
  return testCon;
}

//

function promiseGot( test )
{
  var testMsg = 'testMsg';
  var testCon = new _.Consequence().give( null )

  /* */

  .doThen( function()
  {
    test.case = 'no resource';
    var con = new _.Consequence();
    var promise = con.promiseGot();
    test.identical( con.resourcesGet().length, 0 );
    test.identical( con.competitorsEarlyGet().length, 1 );
    promise.then( function( got )
    {
      test.identical( 0, 1 );
    })
    return null;
  })

  /* */

  .doThen( function()
  {
    test.case = 'single resource';
    var con = new _.Consequence();
    con.give( testMsg );
    test.identical( con.resourcesGet().length, 1 );
    var promise = con.promiseGot();
    promise.then( function( got )
    {
      test.identical( got, testMsg );
      test.is( _.promiseIs( promise ) );
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
    })
    return _.Consequence.From( promise );
  })

  /* */

  .doThen( function()
  {
    test.case = 'single error';
    var con = new _.Consequence();
    con.error( testMsg );
    test.identical( con.resourcesGet().length, 1 );
    var promise = con.promiseGot();
    promise.catch( function( err )
    {
      test.identical( err, testMsg );
      test.is( _.promiseIs( promise ) );
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
    })
    return _.Consequence.From( promise );
  })

  /* */

  .doThen( function()
  {
    test.case = 'several resources';
    var con = new _.Consequence();
    con.give( testMsg  + 1 );
    con.give( testMsg  + 2 );
    con.give( testMsg  + 3 );
    test.identical( con.resourcesGet().length, 3 );
    var promise = con.promiseGot();
    promise.then( function( got )
    {
      test.identical( got, testMsg + 1 );
      test.is( _.promiseIs( promise ) );
      test.identical( con.resourcesGet().length, 2 );
      test.identical( con.competitorsEarlyGet().length, 0 );
    })
    return _.Consequence.From( promise );
  })

  /* */

  .doThen( function()
  {
    wConsequence.prototype.asyncGiving = 1;
    wConsequence.prototype.asyncTaking = 0;
    return null;
  })

  /* */

  .doThen( function()
  {
    test.case = 'async giving, single resource';
    var con = new _.Consequence();
    var promise = con.promiseGot();
    con.give( testMsg );
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 1 );
    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesGet().length, 0 );
        test.identical( con.competitorsEarlyGet().length, 0 );
      });
      return _.Consequence.From( promise );
    })
  })

  /* */

  .doThen( function()
  {
    test.case = 'async giving, single error';
    var con = new _.Consequence();
    var promise = con.promiseGot();
    con.error( testMsg );
    promise.catch( function( err )
    {
      test.identical( err, testMsg );
      test.is( _.promiseIs( promise ) );
    });
    test.identical( con.resourcesGet().length, 1 );
    test.identical( con.competitorsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      return _.Consequence.From( promise );
    });
  })


  /* */

  .doThen( function()
  {
    test.case = 'async giving, several resources';
    var con = new _.Consequence();
    var promise = con.promiseGot();
    con.give( testMsg  + 1 );
    con.give( testMsg  + 2 );
    con.give( testMsg  + 3 );
    test.identical( con.resourcesGet().length, 3 );
    test.identical( con.competitorsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg + 1 );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesGet().length, 2 );
        test.identical( con.competitorsEarlyGet().length, 0 );
      })
      return _.Consequence.From( promise );
    })
  })

  /* */

  .doThen( function()
  {
    wConsequence.prototype.asyncGiving = 0;
    wConsequence.prototype.asyncTaking = 1;
    return null;
  })

  /* */

  .doThen( function()
  {
    test.case = 'async taking, single resource';
    var con = new _.Consequence();
    con.give( testMsg );
    var promise = con.promiseGot();
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 1 );
    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesGet().length, 0 );
        test.identical( con.competitorsEarlyGet().length, 0 );
      });
      return _.Consequence.From( promise );
    })
  })

  /* */

  .doThen( function()
  {
    test.case = 'async taking, error resource';
    var con = new _.Consequence();
    con.error( testMsg );
    var promise = con.promiseGot();
    promise.catch( function( err )
    {
      test.identical( err, testMsg );
      test.is( _.promiseIs( promise ) );
    });
    test.identical( con.resourcesGet().length, 1 );
    test.identical( con.competitorsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      return _.Consequence.From( promise );
    });
  })

  /* */

  .doThen( function()
  {
    test.case = 'async taking, several resources';
    var con = new _.Consequence();
    con.give( testMsg  + 1 );
    con.give( testMsg  + 2 );
    con.give( testMsg  + 3 );
    var promise = con.promiseGot();
    test.identical( con.resourcesGet().length, 3 );
    test.identical( con.competitorsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg + 1 );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesGet().length, 2 );
        test.identical( con.competitorsEarlyGet().length, 0 );
      })
      return _.Consequence.From( promise );
    })
  })

  /* */

  .doThen( function()
  {
    wConsequence.prototype.asyncGiving = 1;
    wConsequence.prototype.asyncTaking = 1;
    return null;
  })

  /* */

  .doThen( function()
  {
    test.case = 'async taking+giving signle resource';
    var con = new _.Consequence();
    con.give( testMsg );
    var promise = con.promiseGot();
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 1 );
    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesGet().length, 0 );
        test.identical( con.competitorsEarlyGet().length, 0 );
      });
      return _.Consequence.From( promise );
    })
  })

  /* */

  .doThen( function()
  {
    test.case = 'async taking+giving error resource';
    var con = new _.Consequence();
    con.error( testMsg );
    var promise = con.promiseGot();
    promise.catch( function( err )
    {
      test.identical( err, testMsg );
      test.is( _.promiseIs( promise ) );
    });
    test.identical( con.resourcesGet().length, 1 );
    test.identical( con.competitorsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      return _.Consequence.From( promise );
    });
  })

  /* */

  .doThen( function()
  {
    test.case = 'async taking+giving several resources';
    var con = new _.Consequence();
    con.give( testMsg  + 1 );
    con.give( testMsg  + 2 );
    con.give( testMsg  + 3 );
    var promise = con.promiseGot();
    test.identical( con.resourcesGet().length, 3 );
    test.identical( con.competitorsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg + 1 );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesGet().length, 2 );
        test.identical( con.competitorsEarlyGet().length, 0 );
      })
      return _.Consequence.From( promise );
    })
  })
  .doThen( function()
  {
    wConsequence.prototype.asyncGiving = 0;
    wConsequence.prototype.asyncTaking = 0;
    return null;
  })

  return testCon;
}

//

function doThen( test )
{
  var c = this;
  var amode = _.Consequence.asyncModeGet();
  var testMsg = 'msg';
  var testCon = new _.Consequence().give( null )

  .doThen( function()
  {
    _.Consequence.asyncModeSet([ 0, 0 ]);
    test.case += ', no resource'
    return null;
  })
  .doThen( function()
  {
    var con = new _.Consequence();
    con.doThen( () => test.identical( 0, 1 ) );
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 );
    return null;
  })

  .doThen( function()
  {
    _.Consequence.asyncModeSet([ 1, 0 ]);
    test.case += ', no resource'
    return null;
  })
  .doThen( function()
  {
    var con = new _.Consequence();
    con.doThen( () => test.identical( 0, 1 ) );
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 );
    return null;
  })

  .doThen( function()
  {
    _.Consequence.asyncModeSet([ 0, 1 ]);
    test.case += ', no resource'
    return null;
  })
  .doThen( function()
  {
    var con = new _.Consequence();
    con.doThen( () => test.identical( 0, 1 ) );
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 );
    return null;
  })

  .doThen( function()
  {
    _.Consequence.asyncModeSet([ 1, 1 ]);
    test.case += ', no resource'
    return null;
  })
  .doThen( function()
  {
    var con = new _.Consequence();
    con.doThen( () => test.identical( 0, 1 ) );
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 );
    return null;
  })

   /* asyncTaking : 0, asyncGiving : 0 */

  .doThen( function()
  {
    _.Consequence.asyncModeSet([ 0, 0 ]);
    test.case += ', single resource, competitor is a routine'
    return null;
  })
  .doThen( function()
  {
    function competitor( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg );
      return null;
    }
    var con = new _.Consequence();
    con.give( testMsg );
    test.identical( con.resourcesGet().length, 1 )
    test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : testMsg } )
    con.doThen( competitor );
    test.identical( con.competitorsEarlyGet().length, 0 );
    test.identical( con.resourcesGet().length, 1 )
    test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : null } );

    return con;
  })

  /* asyncTaking : 1, asyncGiving : 0 */

  .doThen( function()
  {
    _.Consequence.asyncModeSet([ 1, 0 ]);
    test.case += ', single resource, competitor is a routine'
    return null;
  })
  .doThen( function()
  {
    function competitor( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg );
      return null;
    }
    var con = new _.Consequence();
    con.give( testMsg );
    con.doThen( competitor );
    test.identical( con.resourcesGet().length, 1 )
    test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : testMsg } )
    test.identical( con.competitorsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 1 )
      test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : null } )
    })
  })

  /* asyncTaking : 0, asyncGiving : 1 */

  .doThen( function()
  {
    _.Consequence.asyncModeSet([ 0, 1 ]);
    test.case += ', single resource, competitor is a routine'
    return null;
  })
  .doThen( function()
  {
    function competitor( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg );
      return null;
    }
    var con = new _.Consequence();
    con.give( testMsg );

    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 1 )
      test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : testMsg } )
      test.identical( con.competitorsEarlyGet().length, 0 );

      con.doThen( competitor );
      return null;
    })
    .doThen( function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 )
      test.identical( con.resourcesGet().length, 1 )
      test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : null } )
      return null;
    })
  })

  /* asyncTaking : 1, asyncGiving : 1 */

   .doThen( function()
  {
    _.Consequence.asyncModeSet([ 1, 1 ]);
    test.case += ', single resource, competitor is a routine'
    return null;
  })
  .doThen( function()
  {
    function competitor( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg );
      return null;
    }
    var con = new _.Consequence();
    con.give( testMsg );
    con.doThen( competitor );
    test.identical( con.competitorsEarlyGet().length, 1 )
    test.identical( con.resourcesGet().length, 1 )
    test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : testMsg } )
    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 )
      test.identical( con.resourcesGet().length, 1 )
      test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : null } )
      return null;
    })

  })

  /* asyncTaking : 0, asyncGiving : 0 */

   .doThen( function()
  {
    _.Consequence.asyncModeSet([ 0, 0 ]);
    test.case += ', several doThen, competitor is a routine';
    return null;
  })
  .doThen( function()
  {
    var con = new _.Consequence();
    con.give( testMsg );
    con.doThen( function( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg );
      return testMsg + 1;
    });
    con.doThen( function( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg + 1);
      return testMsg + 2;
    });
    con.doThen( function( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg + 2);
      return testMsg + 3;
    });
    test.identical( con.competitorsEarlyGet().length, 0 )
    test.identical( con.resourcesGet().length, 1 )
    test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : testMsg + 3 } );

  })

  /* asyncTaking : 1, asyncGiving : 0 */

   .doThen( function()
  {
    _.Consequence.asyncModeSet([ 1, 0 ]);
    test.case += ', several doThen, competitor is a routine';
    return null;
  })
  .doThen( function()
  {
    var con = new _.Consequence();
    con.give( testMsg );
    con.doThen( function( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg );
      return testMsg + 1;
    });
    con.doThen( function( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg + 1);
      return testMsg + 2;
    });
    con.doThen( function( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg + 2);
      return testMsg + 3;
    });
    test.identical( con.competitorsEarlyGet().length, 3 )
    test.identical( con.resourcesGet().length, 1 )
    test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : testMsg } );

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 )
      test.identical( con.resourcesGet().length, 1 )
      test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : testMsg + 3 } );
      return null;
    })

  })

  /* asyncTaking : 0, asyncGiving : 1 */

   .doThen( function()
  {
    _.Consequence.asyncModeSet([ 0, 1 ]);
    test.case += ', several doThen, competitor is a routine';
    return null;
  })
  .doThen( function()
  {
    var con = new _.Consequence();
    con.give( testMsg );

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 )
      test.identical( con.resourcesGet().length, 1 )
      test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : testMsg } );

      con.doThen( function( err, got )
      {
        test.identical( err , undefined )
        test.identical( got , testMsg );
        return testMsg + 1;
      });
      con.doThen( function( err, got )
      {
        test.identical( err , undefined )
        test.identical( got , testMsg + 1);
        return testMsg + 2;
      });
      con.doThen( function( err, got )
      {
        test.identical( err , undefined )
        test.identical( got , testMsg + 2);
        return testMsg + 3;
      });

      return con;
    })
    .doThen( function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 )
      test.identical( con.resourcesGet().length, 1 )
      test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : testMsg + 3 } );
      return null;
    })

  })

  /* asyncTaking : 1, asyncGiving : 1 */

   .doThen( function()
  {
    _.Consequence.asyncModeSet([ 1, 1 ]);
    test.case += ', several doThen, competitor is a routine';
    return null;
  })
  .doThen( function()
  {
    var con = new _.Consequence();
    con.give( testMsg );

    con.doThen( function( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg );
      return testMsg + 1;
    });
    con.doThen( function( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg + 1);
      return testMsg + 2;
    });
    con.doThen( function( err, got )
    {
      test.identical( err , undefined )
      test.identical( got , testMsg + 2);
      return testMsg + 3;
    });

    test.identical( con.competitorsEarlyGet().length, 3 );
    test.identical( con.resourcesGet().length, 1 );
    test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : testMsg } );

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 1 );
      test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : testMsg + 3} );
      return null;
    })

  })

   /* asyncTaking : 0, asyncGiving : 0 */

   .doThen( function()
  {
    _.Consequence.asyncModeSet([ 0, 0 ]);
    test.case += ', single resource, consequence as a competitor';
    return null;
  })
  .doThen( function()
  {
    var con = new _.Consequence();
    var con2 = new _.Consequence();
    var con2TakerFired = false;
    con.give( testMsg );
    /* doThen only transfers the copy of messsage to the competitor without waiting for response */
    con.doThen( con2 );
    con.got( function( err, got )
    {
      test.identical( got, testMsg );
      test.identical( con2TakerFired, false );
      test.identical( con2.resourcesGet().length, 1 );
    });

    con2.doThen( function( err, got )
    {
      test.identical( got, testMsg )
      con2TakerFired = true;
      return null;
    });

    con2.doThen( function()
    {
      test.identical( con2TakerFired, true );
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet().length, 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

    return con2;
  })

  /* asyncTaking : 1, asyncGiving : 0 */

   .doThen( function()
  {
    _.Consequence.asyncModeSet([ 1, 0 ]);
    test.case += ', single resource, consequence as a competitor';
    return null;
  })
  .doThen( function()
  {
    var con = new _.Consequence();
    var con2 = new _.Consequence();
    var con2TakerFired = false;
    con.give( testMsg );
    con.doThen( con2 );
    con.got( function( err, got )
    {
      test.identical( got, testMsg );
      test.identical( con2TakerFired, true );
      test.identical( con2.resourcesGet().length, 0 );
    });

    con2.got( function( err, got )
    {
      test.identical( got, testMsg )
      con2TakerFired = true;
    });

    test.identical( con2TakerFired, false );
    test.identical( con.resourcesGet().length, 1 );
    test.identical( con.competitorsEarlyGet().length, 2 );
    test.identical( con2.competitorsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      test.identical( con2TakerFired, true );
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet().length, 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    })

  })

  /* asyncTaking : 0, asyncGiving : 1 */

   .doThen( function()
  {
    _.Consequence.asyncModeSet([ 0, 1 ]);
    test.case += ', single resource, consequence as a competitor';
    return null;
  })
  .doThen( function()
  {
    var con = new _.Consequence();
    var con2 = new _.Consequence();
    var con2TakerFired = false;
    con.give( testMsg );

    test.identical( con2TakerFired, false );
    test.identical( con.resourcesGet().length, 1 );
    test.identical( con.competitorsEarlyGet().length, 0 );
    test.identical( con2.competitorsEarlyGet().length, 0 );

    return _.timeOut( 1, function()
    {
      con.doThen( con2 );
      con.got( function( err, got )
      {
        test.identical( got, testMsg );
        test.identical( con2TakerFired, false );
        test.identical( con2.resourcesGet().length, 1 );
      });

      con2.doThen( function( err, got )
      {
        test.identical( got, testMsg );
        con2TakerFired = true;
      });

      return con2;
    })
    .doThen( function()
    {
      test.identical( con2TakerFired, true );
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet().length, 1 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /* asyncTaking : 1, asyncGiving : 1 */

   .doThen( function()
  {
    _.Consequence.asyncModeSet([ 1, 1 ]);
    test.case += ', single resource, consequence as a competitor';
    return null;
  })
  .doThen( function()
  {
    var con = new _.Consequence();
    var con2 = new _.Consequence();
    var con2TakerFired = false;
    con.give( testMsg );
    con.doThen( con2 );
    con.got( function( err, got )
    {
      test.identical( got, testMsg );
      test.identical( con2TakerFired, false );
      test.identical( con2.resourcesGet().length, 1 );
    });

    con2.got( function( err, got )
    {
      test.identical( got, testMsg );
      con2TakerFired = true;
    });

    test.identical( con2TakerFired, false );
    test.identical( con.resourcesGet().length, 1 );
    test.identical( con.competitorsEarlyGet().length, 2 );
    test.identical( con2.competitorsEarlyGet().length, 1 );
    test.identical( con2.resourcesGet().length, 0 );

    return _.timeOut( 1, function()
    {
      test.identical( con2TakerFired, true );
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet().length, 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    })
  })

  /* asyncTaking : 0, asyncGiving : 0 */

   .doThen( function()
  {
    _.Consequence.asyncModeSet([ 0, 0 ]);
    test.case += 'competitor returns consequence with msg';
    return null;
  })
  .doThen( function()
  {
    var con = new _.Consequence();
    var con2 = new _.Consequence();
    con.give( null );
    con.doThen( function()
    {
      return con2.give( testMsg );
    });

    test.identical( con.competitorsEarlyGet().length, 0 );
    test.identical( con.resourcesGet().length, 1 );
    test.identical( con.resourcesGet()[ 0 ].argument, testMsg );

    test.identical( con2.resourcesGet().length, 1 );
    test.identical( con2.resourcesGet()[ 0 ].argument, testMsg );

    return null;

  })

  /* asyncTaking : 1, asyncGiving : 0 */

   .doThen( function()
  {
    _.Consequence.asyncModeSet([ 1, 0 ]);
    test.case += 'competitor returns consequence with msg';
    return null;
  })
  .doThen( function()
  {
    var con = new _.Consequence();
    var con2 = new _.Consequence();
    con.give( null );
    con.doThen( function()
    {
      return con2.give( testMsg );
    });

    test.identical( con.competitorsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 1 );
      test.identical( con.resourcesGet()[ 0 ].argument, testMsg );

      test.identical( con2.resourcesGet().length, 1 );
      test.identical( con2.resourcesGet()[ 0 ].argument, testMsg );
      return null;
    })
  })

  /* asyncTaking : 0, asyncGiving : 1 */

   .doThen( function()
  {
    _.Consequence.asyncModeSet([ 0, 1 ]);
    test.case += 'competitor returns consequence with msg';
    return null;
  })
  .doThen( function()
  {
    var con = new _.Consequence();
    var con2 = new _.Consequence();
    con.give( null );

    test.identical( con.resourcesGet().length, 1 );

    return _.timeOut( 1, function()
    {
      con.doThen( function()
      {
        return con2.give( testMsg );
      });

      return con;
    })
    .doThen( function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 1 );
      test.identical( con.resourcesGet()[ 0 ].argument, testMsg );

      test.identical( con2.resourcesGet().length, 1 );
      test.identical( con2.resourcesGet()[ 0 ].argument, testMsg );
      return null;
    })
  })

  /* asyncTaking : 1, asyncGiving : 1 */

   .doThen( function()
  {
    _.Consequence.asyncModeSet([ 1, 1 ]);
    test.case += 'competitor returns consequence with msg';
    return null;
  })
  .doThen( function()
  {
    var con = new _.Consequence();
    var con2 = new _.Consequence();
    con.give( null );
    con.doThen( function()
    {
      return con2.give( testMsg );
    });

    test.identical( con.resourcesGet().length, 1 );

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 1 );
      test.identical( con.resourcesGet()[ 0 ].argument, testMsg );

      test.identical( con2.resourcesGet().length, 1 );
      test.identical( con2.resourcesGet()[ 0 ].argument, testMsg );
      return null;
    })
  })

  /* */

  testCon.doThen( () =>
  {
    _.Consequence.asyncModeSet( amode );
    return null;
  });

  return testCon;
}

//

function promiseThen( test )
{
  var testMsg = 'testMsg';
  var testCon = new _.Consequence().give( null )

  /* */

  .doThen( function()
  {
    test.case = 'no resource';
    var con = new _.Consequence();
    var promise = con.promiseThen();
    test.identical( con.resourcesGet().length, 0 );
    test.identical( con.competitorsEarlyGet().length, 1 );
    promise.then( function( got )
    {
      test.identical( 0, 1 );
    })
  })

  /* */

  .doThen( function()
  {
    test.case = 'single resource';
    var con = new _.Consequence();
    con.give( testMsg );
    test.identical( con.resourcesGet().length, 1 );
    var promise = con.promiseThen();
    promise.then( function( got )
    {
      test.identical( got, testMsg );
      test.is( _.promiseIs( promise ) );
      test.identical( con.resourcesGet(), [{ error : undefined, argument : testMsg }] );
      test.identical( con.competitorsEarlyGet().length, 0 );
    })

    return _.Consequence.From( promise );
  })

  /* */

  .doThen( function()
  {
    test.case = 'error resource';
    var con = new _.Consequence();
    con.error( testMsg );
    test.identical( con.resourcesGet().length, 1 );
    var promise = con.promiseThen();
    promise.catch( function( err )
    {
      test.identical( err, testMsg );
      test.is( _.promiseIs( promise ) );
      test.identical( con.resourcesGet(), [{ error : testMsg, argument : undefined }] );
      test.identical( con.competitorsEarlyGet().length, 0 );
    })
    return _.Consequence.From( promise );
  })

  /* */

  .doThen( function()
  {
    test.case = 'several resources';
    var con = new _.Consequence();
    con.give( testMsg  + 1 );
    con.give( testMsg  + 2 );
    con.give( testMsg  + 3 );
    test.identical( con.resourcesGet().length, 3 );
    var promise = con.promiseThen();
    promise.then( function( got )
    {
      test.identical( got, testMsg + 1 );
      test.is( _.promiseIs( promise ) );
      test.identical( con.resourcesGet().length, 3 );
      test.identical( con.competitorsEarlyGet().length, 0 );
    })
    return _.Consequence.From( promise );
  })

  /* */

  .doThen( function()
  {
    wConsequence.prototype.asyncGiving = 1;
    wConsequence.prototype.asyncTaking = 0;
  })

  /* */

  .doThen( function()
  {
    test.case = 'async giving, single resource';
    var con = new _.Consequence();
    var promise = con.promiseThen();
    con.give( testMsg );
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 1 );
    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesGet(), [{ error : undefined, argument : testMsg }] );
        test.identical( con.competitorsEarlyGet().length, 0 );
      });
      return _.Consequence.From( promise );
    })
  })

  /* */

  .doThen( function()
  {
    test.case = 'async giving, error resource';
    var con = new _.Consequence();
    var promise = con.promiseThen();
    promise.catch( function( err )
    {
      test.identical( err, testMsg );
      test.is( _.promiseIs( promise ) );
    });
    con.error( testMsg );
    test.identical( con.resourcesGet().length, 1 );
    test.identical( con.competitorsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet(), [{ error : testMsg, argument : undefined }] );
      test.identical( con.competitorsEarlyGet().length, 0 );
      return _.Consequence.From( promise );
    });
  })

  /* */

  .doThen( function()
  {
    test.case = 'async giving, several resources';
    var con = new _.Consequence();
    var promise = con.promiseThen();
    con.give( testMsg  + 1 );
    con.give( testMsg  + 2 );
    con.give( testMsg  + 3 );
    test.identical( con.resourcesGet().length, 3 );
    test.identical( con.competitorsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg + 1 );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesGet().length, 3 );
        test.identical( con.competitorsEarlyGet().length, 0 );
      })
      return _.Consequence.From( promise );
    })
  })

  /* */

  .doThen( function()
  {
    wConsequence.prototype.asyncGiving = 0;
    wConsequence.prototype.asyncTaking = 1;
  })

  /* */

  .doThen( function()
  {
    test.case = 'async taking, single resource';
    var con = new _.Consequence();
    con.give( testMsg );
    var promise = con.promiseThen();
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 1 );
    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesGet(), [{ error : undefined, argument : testMsg }] );
        test.identical( con.competitorsEarlyGet().length, 0 );
      });
      return _.Consequence.From( promise );
    })
  })

  /* */

  .doThen( function()
  {
    test.case = 'async taking, error resource';
    var con = new _.Consequence();
    con.error( testMsg );
    var promise = con.promiseThen();
    promise.catch( function( err )
    {
      test.identical( err, testMsg );
      test.is( _.promiseIs( promise ) );
    });
    test.identical( con.resourcesGet().length, 1 );
    test.identical( con.competitorsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet(), [{ error : testMsg, argument : undefined }] );
      test.identical( con.competitorsEarlyGet().length, 0 );
      return _.Consequence.From( promise );
    });
  })

  /* */

  .doThen( function()
  {
    test.case = 'async taking, several resources';
    var con = new _.Consequence();
    con.give( testMsg  + 1 );
    con.give( testMsg  + 2 );
    con.give( testMsg  + 3 );
    var promise = con.promiseThen();
    test.identical( con.resourcesGet().length, 3 );
    test.identical( con.competitorsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg + 1 );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesGet().length, 3 );
        test.identical( con.competitorsEarlyGet().length, 0 );
      })
      return _.Consequence.From( promise );
    })
  })

  /* */

  .doThen( function()
  {
    wConsequence.prototype.asyncGiving = 1;
    wConsequence.prototype.asyncTaking = 1;
  })

  /* */

  .doThen( function()
  {
    test.case = 'async taking+giving, single resource';
    var con = new _.Consequence();
    con.give( testMsg );
    var promise = con.promiseThen();
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 1 );
    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesGet(), [{ error : undefined, argument : testMsg }] );
        test.identical( con.competitorsEarlyGet().length, 0 );
      });
      return _.Consequence.From( promise );
    })
  })

  /* */

  .doThen( function()
  {
    test.case = 'async taking+giving, error resource';
    var con = new _.Consequence();
    con.error( testMsg );
    var promise = con.promiseThen();
    promise.catch( function( err )
    {
      test.identical( err, testMsg );
      test.is( _.promiseIs( promise ) );
    });
    test.identical( con.resourcesGet().length, 1 );
    test.identical( con.competitorsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet(), [{ error : testMsg, argument : undefined }] );
      test.identical( con.competitorsEarlyGet().length, 0 );
      return _.Consequence.From( promise );
    });
  })

  /* */

  .doThen( function()
  {
    test.case = 'async taking+giving, several resources';
    var con = new _.Consequence();
    con.give( testMsg  + 1 );
    con.give( testMsg  + 2 );
    con.give( testMsg  + 3 );
    var promise = con.promiseThen();
    test.identical( con.resourcesGet().length, 3 );
    test.identical( con.competitorsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      promise.then( function( got )
      {
        test.identical( got, testMsg + 1 );
        test.is( _.promiseIs( promise ) );
        test.identical( con.resourcesGet().length, 3 );
        test.identical( con.competitorsEarlyGet().length, 0 );
      })
      return _.Consequence.From( promise );
    })
  })
  .doThen( function()
  {
    wConsequence.prototype.asyncGiving = 0;
    wConsequence.prototype.asyncTaking = 0;
    return null;
  })

  return testCon;
}

//

// function thenSealed_( test )
// {
//
//   var testCheck1 =
//
//     {
//       givSequence : [ 5 ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//         [
//           { err : undefined, value : 5, takerId : 'taker1' }
//         ],
//         throwErr : false
//       }
//     },
//     testCheck2 =
//     {
//       givSequence :
//       [
//         'err msg'
//       ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//         [
//           { err : 'err msg', value : void 0, takerId : 'taker1' }
//         ],
//         throwErr : false
//       }
//     },
//     testCheck3 =
//     {
//       givSequence : [ 5, 4 ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//         [
//           { err : undefined, value : 5, takerId : 'taker1' },
//           { err : undefined, value : 4, takerId : 'taker2' }
//         ],
//         throwErr : false
//       }
//     },
//     testCheck4 =
//     {
//       givSequence : [ 5 ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//         [
//           {
//             err : undefined,
//             value : 5,
//             takerId : 'taker1',
//             context : 'ContextConstructor',
//             sealed : 'bar' ,
//             contVariable : 'foo'
//           },
//         ],
//         throwErr : false
//       }
//     };
//
//
//   /* common wConsequence corespondent tests. */
//
//   test.case = 'single value in give sequence, and single taker : attached taker after value resolved';
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//     }
//
//     var con = _.Consequence();
//     con.give( givSequence.shift() );
//     try
//     {
//       con.thenSealed( undefined, testTaker1, [] );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck1 );
//
//   /**/
//
//   test.case = 'single err in give sequence, and single taker : attached taker after value resolved';
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//     }
//
//     var con = _.Consequence();
//     try
//     {
//       con.error( givSequence.shift() );
//       con.thenSealed( undefined, testTaker1, [] );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck2 );
//
//   /**/
//
//   test.case = 'test thenSealed in chain';
//
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//       value++;
//       return value;
//     }
//
//     function testTaker2( err, value )
//     {
//       var takerId = 'taker2';
//       got.gotSequence.push( { err, value, takerId } );
//     }
//
//     var con = _.Consequence();
//     for (var given of givSequence)
//       con.give( given );
//
//     try
//     {
//       con.thenSealed( undefined, testTaker1, [] );
//       con.thenSealed( undefined, testTaker2, [] );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck3 );
//
//   /* test particular _onceGot features test. */
//
//   test.case = 'thenSealed with sealed context and argument';
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( sealed, err, value )
//     {
//       console.log( sealed + err + value )
//       var takerId = 'taker1',
//         context = this.constructor.name,
//         contVariable = this.contVariable;
//         got.gotSequence.push( { err, value, takerId, context, contVariable, sealed } );
//     }
//
//     function ContextConstructor()
//     {
//       this.contVariable = 'foo';
//     }
//
//     var con = _.Consequence();
//
//     for( var given of givSequence )
//     {
//       con.give( given );
//     }
//
//     try
//     {
//       con.thenSealed( new ContextConstructor(), testTaker1, [ 'bar' ] );
//     }
//     catch( err )
//     {
//       console.log(err);
//       got.throwErr = !! err;
//     }
//     console.log(JSON.stringify(expected));
//     test.identical( got, expected );
//   } )( testCheck4 );
//
//
//   if( Config.debug )
//   {
//     var conDeb1 = _.Consequence();
//
//     test.case = 'missed context arguments';
//     test.shouldThrowError( function()
//     {
//       conDeb1.thenSealed( function( err, val) { logger.log( 'foo' ); } );
//     } );
//   }
//
// };

//

// function split( test )
// {
//   var testCheck1 =
//
//     {
//       givSequence : [ 5 ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//           [
//             { err : undefined, value : 5, takerId : 'taker1' }
//           ],
//         throwErr : false
//       }
//     },
//     testCheck2 =
//     {
//       givSequence :
//         [ 5 ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//           [
//             { err : undefined, value : 5, takerId : 'taker1' }
//           ],
//         throwErr : false
//       }
//     },
//     testCheck3 =
//     {
//       givSequence : [ 5, 4 ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//           [
//             { err : undefined, value : 5, takerId : 'taker1' },
//           ],
//         throwErr : false
//       }
//     };
//
//
//   /* common wConsequence corespondent tests. */
//
//   test.case = 'then clone : run after resolve value';
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//     }
//
//     var newCon;
//     var con = _.Consequence();
//     con.give( givSequence.shift() );
//     try
//     {
//       newCon = con.split();
//       newCon.got( testTaker1 )
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck1 );
//
//   /**/
//
//   test.case = 'then clone : run before resolve value';
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//     }
//
//     var newCon;
//     var con = _.Consequence();
//     try
//     {
//       newCon = con.split();
//       newCon.got( testTaker1 );
//       con.give( givSequence.shift() );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck2 );
//
//   /**/
//
//   test.case = 'test thenSealed in chain';
//
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//       value++;
//       return value;
//     }
//
//     function testTaker2( err, value )
//     {
//       var takerId = 'taker2';
//       got.gotSequence.push( { err, value, takerId } );
//     }
//
//     var con = _.Consequence();
//     for (var given of givSequence)
//       con.give( given );
//
//     var newCon;
//     try
//     {
//       newCon = con.split();
//       newCon.got( testTaker1 );
//       newCon.got( testTaker2 );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck3 );
// };

//

function split( test )
{
  var testCon = new _.Consequence().give( null )

  .doThen( function()
  {
    test.case = 'split : run after resolve value';
    var con = new _.Consequence().give( 5 );
    var con2 = con.split();
    test.identical( con2.resourcesGet().length, 1 );
    con2.got( function( err, got )
    {
      test.identical( got, 5 );
      test.identical( err, undefined );
    });

    test.identical( con.resourcesGet().length, 1 );
    test.identical( con2.resourcesGet().length, 0 );
    return null;
  })

  .doThen( function()
  {
    test.case = 'split : run before resolve value';
    var con = new _.Consequence();
    var con2 = con.split();
    con2.got( function( err, got )
    {
      test.identical( got, 5 );
      test.identical( err, undefined );
    });
    con.give( 5 );
    test.identical( con.resourcesGet().length, 1 );
    test.identical( con2.resourcesGet().length, 0 );
    return null;
  })

  .doThen( function()
  {
    test.case = 'test split in chain';
    var _got = [];
    var _err = [];
    function competitor( err, got )
    {
      _got.push( got );
      _err.push( err );
    }

    var con = new _.Consequence();
    con.give( 5 );
    con.give( 6 );
    test.identical( con.resourcesGet().length, 2 );
    var con2 = con.split();
    test.identical( con2.resourcesGet().length, 1 );
    con2.got( competitor );
    con2.got( competitor );

    test.identical( con2.resourcesGet().length, 0 );
    test.identical( con2.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 2 );
    test.identical( _got, [ 5 ] )
    test.identical( _err, [ undefined ] )
    return null;
  })

  .doThen( function()
  {
    test.case = 'passing competitor as argument';
    var _got = [];
    var _err = [];
    function competitor( err, got )
    {
      _got.push( got );
      _err.push( err );
      return null;
    }

    var con = new _.Consequence();
    con.give( 5 );
    con.give( 6 );
    test.identical( con.resourcesGet().length, 2 );
    var con2 = con.split( competitor );

    test.identical( con2.resourcesGet().length, 1 );
    test.identical( con2.resourcesGet()[ 0 ], { error : undefined, argument : null } );
    test.identical( con2.competitorsEarlyGet().length, 0 );
    test.identical( con.resourcesGet().length, 2 );
    test.identical( _got, [ 5 ] )
    test.identical( _err, [ undefined ] )
    return null;
  })

  return testCon;
}

//

// function thenReportError( test )
// {
//
//   var testCheck1 =
//
//     {
//       givSequence : [ 5 ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence : [],
//         throwErr : false
//       }
//     },
//     testCheck2 =
//     {
//       givSequence :
//         [
//           'err msg'
//         ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//           [],
//         throwErr : false
//       }
//     },
//     testCheck3 =
//     {
//       givSequence : [ 5, 4 ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//           [
//             { err : undefined, value : 5, takerId : 'taker1' },
//             { err : undefined, value : 4, takerId : 'taker2' }
//           ],
//         throwErr : false
//       }
//     },
//     testCheck4 =
//     {
//       givSequence : [ 5, 4 ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//           [
//             { err : undefined, value : 5, takerId : 'taker1' },
//             { err : undefined, value : 4, takerId : 'taker2' }
//           ],
//         throwErr : false
//       }
//     };
//
//
//   /* common wConsequence corespondent tests. */
//
//   test.case = 'single value in give sequence';
//   ( function( { givSequence, got, expected }  )
//   {
//     var con = _.Consequence();
//     con.give( givSequence.shift() );
//     try
//     {
//       con.thenReportError();
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck1 );
//
//   /**/
//
//   test.case = 'single err in give sequence';
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//     }
//
//     var con = _.Consequence();
//     try
//     {
//       con.error( givSequence.shift() );
//       con.thenReportError();
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck2 );
//
//   /**/
//
//   test.case = 'test thenSealed in chain';
//
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//       value++;
//       return value;
//     }
//
//     function testTaker2( err, value )
//     {
//       var takerId = 'taker2';
//       got.gotSequence.push( { err, value, takerId } );
//     }
//
//     var con = _.Consequence();
//     for (var given of givSequence)
//       con.give( given );
//
//     try
//     {
//       con.thenReportError();
//       con.got( testTaker1 );
//       con.got( testTaker2 );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck3 );
//   //
//   /* test particular _onceGot features test. */
//
//   test.case = 'test thenSealed in chain #2';
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//       value++;
//       return value;
//     }
//
//     function testTaker2( err, value )
//     {
//       var takerId = 'taker2';
//       got.gotSequence.push( { err, value, takerId } );
//     }
//
//     var con = _.Consequence();
//     try
//     {
//       con.thenReportError();
//       con.got( testTaker1 );
//       con.got( testTaker2 );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//
//     for (var given of givSequence)
//       con.give( given );
//
//     test.identical( got, expected );
//   } )( testCheck4 );
//
//
//   if( Config.debug )
//   {
//     var conDeb1 = _.Consequence();
//
//     test.case = 'called thenReportError with any argument';
//     test.shouldThrowError( function()
//     {
//       conDeb1.thenReportError( function( err, val) { logger.log( 'foo' ); } );
//     } );
//   }
//
// };

//

// function tap( test )
// {

//   var testCheck1 =

//     {
//       givSequence : [ 5 ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//           [
//             { err : undefined, value : 5, takerId : 'taker1' }
//           ],
//         throwErr : false
//       }
//     },
//     testCheck2 =
//     {
//       givSequence :
//         [
//           'err msg'
//         ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//           [
//             { err : 'err msg', value : void 0, takerId : 'taker1' }
//           ],
//         throwErr : false
//       }
//     },
//     testCheck3 =
//     {
//       givSequence : [ 5, 4 ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//           [
//             { err : undefined, value : 5, takerId : 'taker1' },
//             { err : undefined, value : 5, takerId : 'taker2' },
//             { err : undefined, value : 5, takerId : 'taker3' }
//           ],
//         throwErr : false
//       }
//     };


//   /* common wConsequence corespondent tests. */

//   test.case = 'single value in give sequence, and single taker : attached taker after value resolved';
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//     }

//     var con = _.Consequence();
//     con.give( givSequence.shift() );
//     try
//     {
//       con.tap( testTaker1 );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck1 );

//   /**/

//   test.case = 'single err in give sequence, and single taker : attached taker after value resolved';
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//     }

//     var con = _.Consequence();
//     try
//     {
//       con.error( givSequence.shift() );
//       con.tap( testTaker1 );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck2 );

//   /**/

//   test.case = 'test tap in chain';

//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//       value++;
//       return value;
//     }

//     function testTaker2( err, value )
//     {
//       var takerId = 'taker2';
//       got.gotSequence.push( { err, value, takerId } );
//     }

//     function testTaker3( err, value )
//     {
//       var takerId = 'taker3';
//       got.gotSequence.push( { err, value, takerId } );
//     }

//     var con = _.Consequence();
//     for (var given of givSequence)
//       con.give( given );

//     try
//     {
//       con.tap( testTaker1 );
//       con.tap( testTaker2 );
//       con.got( testTaker3 );

//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck3 );

//   if( Config.debug )
//   {
//     var conDeb1 = _.Consequence();

//     test.case = 'missed arguments';
//     test.shouldThrowError( function()
//     {
//       conDeb1.tap();
//     } );
//   }

// };

//

function tap( test )
{
  var testMsg = 'msg';
  var testCon = new _.Consequence().give( null )

  /* */

  .doThen( function()
  {
    test.case = 'single value in give sequence, and single taker : attached taker after value resolved';

    var con = new _.Consequence();
    con.give( testMsg );
    con.tap( ( err, got ) => test.identical( got, testMsg ) );
    con.got( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( con.competitorsEarlyGet().length, 0 );
    test.identical( con.resourcesGet().length, 0 );
    return null;
  })

  /* */

  .doThen( function()
  {
    test.case = 'single error and single taker : attached taker after value resolved';

    var con = new _.Consequence();
    con.error( testMsg );
    con.tap( ( err, got ) => test.identical( err, testMsg ) );
    con.got( ( err, got ) => test.identical( err, testMsg ) );
    test.identical( con.competitorsEarlyGet().length, 0 );
    test.identical( con.resourcesGet().length, 0 );
    return null;
  })

  /* */

  .doThen( function()
  {
    test.case = 'test tap in chain';

    var con = new _.Consequence();
    con.give( testMsg );
    con.tap( ( err, got ) => test.identical( got, testMsg ) );
    con.tap( ( err, got ) => test.identical( got, testMsg ) );
    con.got( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( con.competitorsEarlyGet().length, 0 );
    test.identical( con.resourcesGet().length, 0 );
    return null;
  })

   /* */

  .doThen( function()
  {
    if( !Config.debug )
    return;

    test.case = 'missed arguments';

    var con = _.Consequence();

    test.shouldThrowError( function()
    {
      con.tap();
    });

    return null;
  })

  return testCon;
}

//

// function ifErrorThen( test )
// {

//   var testCheck1 =

//     {
//       givSequence : [ 5 ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence : [],
//         throwErr : false
//       }
//     },
//     testCheck2 =
//     {
//       givSequence :
//         [
//           'err msg'
//         ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//           [
//             { err : 'err msg', takerId : 'taker1' }
//           ],
//         throwErr : false
//       }
//     },
//     testCheck3 =
//     {
//       givSequence : [ 5, 'err msg',  4 ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//           [
//             { err : undefined, value : 5, takerId : 'taker3' },
//           ],
//         throwErr : false
//       }
//     };


//   /* common wConsequence corespondent tests. */

//   test.case = 'single value in give sequence, and single taker : attached taker after value resolved';
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, takerId } );
//     }

//     var con = _.Consequence();
//     con.give( givSequence.shift() );
//     try
//     {
//       con.ifErrorThen( testTaker1 );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck1 );

//   /**/

//   test.case = 'single err in give sequence, and single taker : attached taker after value resolved';
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, takerId } );
//     }

//     var con = _.Consequence();
//     try
//     {
//       con.error( givSequence.shift() );
//       con.ifErrorThen( testTaker1 );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck2 );

//   /**/

//   test.case = 'test tap in chain';

//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err,takerId } );
//       value++;
//       return value;
//     }

//     function testTaker2( err )
//     {
//       var takerId = 'taker2';
//       got.gotSequence.push( { err,takerId } );
//     }

//     function testTaker3( err, value )
//     {
//       var takerId = 'taker3';
//       got.gotSequence.push( { err, value, takerId } );
//     }

//     var con = _.Consequence();

//     con.give( givSequence.shift() );
//     con.error( givSequence.shift() );
//     con.give( givSequence.shift() );

//     try
//     {
//       con.ifErrorThen( testTaker1 );
//       con.ifErrorThen( testTaker2 );
//       con.got( testTaker3 );

//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck3 );

//   if( Config.debug )
//   {
//     var conDeb1 = _.Consequence();

//     test.case = 'missed arguments';
//     test.shouldThrowError( function()
//     {
//       conDeb1.ifErrorThen();
//     } );
//   }

// };

//

function ifErrorThen( test )
{
  var testMsg = 'msg';
  var testCon = new _.Consequence().give( null )

  /* common wConsequence corespondent tests. */

  .doThen( function()
  {
    test.case = 'single value in give sequence, and single taker : attached taker after value resolved';

    var con = new _.Consequence();
    con.give( testMsg );
    con.ifErrorThen( ( err ) => { test.identical( 0, 1 ); return null; } );
    con.got( ( err, got ) => test.identical( got, testMsg ));

    test.identical( con.competitorsEarlyGet().length, 0 );
    test.identical( con.resourcesGet().length, 0 );
  })

  /* */

  .doThen( function()
  {
    test.case = 'single err in give sequence, and single taker : attached taker after value resolved';

    var con = new _.Consequence();
    con.error( testMsg );
    con.ifErrorThen( ( err ) => { test.identical( err,testMsg ); return null; });
    con.got( ( err, got ) => test.identical( got, null ) );

    test.identical( con.competitorsEarlyGet().length, 0 );
    test.identical( con.resourcesGet().length, 0 );
  })

  /* */

  .doThen( function()
  {
    test.case = 'test ifErrorThen in chain, regular resource is given before error';

    var con = new _.Consequence();
    con.give( testMsg );
    con.error( testMsg + 1 );
    con.error( testMsg + 2 );

    con.ifErrorThen( ( err ) => { test.identical( 0, 1 ); return null; });
    con.ifErrorThen( ( err ) => { test.identical( 0, 1 ); return null; });
    con.got( ( err, got ) => test.identical( got, testMsg ) );

    test.identical( con.resourcesGet().length, 2 );
    test.identical( con.resourcesGet()[ 0 ].error, testMsg + 1 );
    test.identical( con.resourcesGet()[ 1 ].error, testMsg + 2 );
    test.identical( con.competitorsEarlyGet().length, 0 );
  })

  /* */

  .doThen( function()
  {
    test.case = 'test ifErrorThen in chain, regular resource is given after error';

    var con = new _.Consequence();
    con.error( testMsg + 1 );
    con.error( testMsg + 2 );
    con.give( testMsg );

    con.ifErrorThen( ( err ) => { test.identical( err, testMsg + 1 ); return null; });
    con.ifErrorThen( ( err ) => { test.identical( err, testMsg + 2 ); return null; });
    con.got( ( err, got ) => test.identical( got, testMsg ) );

    test.identical( con.resourcesGet().length, 2 );
    test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : null } );
    test.identical( con.resourcesGet()[ 1 ], { error : undefined, argument : null } );
    test.identical( con.competitorsEarlyGet().length, 0 );
  })

   /* */

  .doThen( function()
  {
    if( !Config.debug )
    return;

    test.case = 'missed arguments';

    var con = _.Consequence();

    test.shouldThrowError( function()
    {
      con.ifErrorThen();
    });
    return null;
  })

  return testCon;
}

//

// function ifNoErrorThen( test )
// {

//   var testCheck1 =

//     {
//       givSequence : [ 5 ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//         [
//           { value : 5, takerId : 'taker1' }
//         ],
//         throwErr : false
//       }
//     },
//     testCheck2 =
//     {
//       givSequence :
//         [
//           'err msg'
//         ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//           [ ],
//         throwErr : false
//       }
//     },
//     testCheck3 =
//     {
//       givSequence : [ 5, 'err msg',  4 ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//           [
//             { value : 5, takerId : 'taker1' },
//             { err : 'err msg', value : void 0, takerId : 'taker3' },
//           ],
//         throwErr : false
//       }
//     };


//   /* common wConsequence corespondent tests. */

//   test.case = 'single value in give sequence, and single taker : attached taker after value resolved';
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { value, takerId } );
//     }

//     var con = _.Consequence();
//     con.give( givSequence.shift() );
//     try
//     {
//       con.ifNoErrorThen( testTaker1 );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck1 );

//   /**/

//   test.case = 'single err in give sequence, and single taker : attached taker after value resolved';
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { value, takerId } );
//     }

//     var con = _.Consequence();
//     try
//     {
//       con.error( givSequence.shift() );
//       con.ifNoErrorThen( testTaker1 );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck2 );

//   /**/

//   test.case = 'test ifNoErrorThen in chain';

//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { value, takerId } );
//       value++;
//       return value;
//     }

//     function testTaker2( value )
//     {
//       var takerId = 'taker2';
//       got.gotSequence.push( {  value, takerId } );
//     }

//     function testTaker3( err, value )
//     {
//       var takerId = 'taker3';
//       got.gotSequence.push( { err, value, takerId } );
//     }

//     var con = _.Consequence();

//     con.give( givSequence.shift() );
//     con.error( givSequence.shift() );
//     con.give( givSequence.shift() );

//     try
//     {
//       con.ifNoErrorThen( testTaker1 );
//       con.ifNoErrorThen( testTaker2 );
//       con.got( testTaker3 );

//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck3 );

//   if( Config.debug )
//   {
//     var conDeb1 = _.Consequence();

//     test.case = 'missed arguments';
//     test.shouldThrowError( function()
//     {
//       conDeb1.ifNoErrorThen();
//     });
//   }

// };

//

function ifNoErrorThen( test )
{
  var testMsg = 'msg';
  var testCon = new _.Consequence().give( null )

  /* common wConsequence corespondent tests. */

  .doThen( function()
  {
    test.case = 'single value in give sequence, and single taker : attached taker after value resolved';

    var con = new _.Consequence();
    con.give( testMsg );
    con.ifNoErrorThen( ( got ) => { test.identical( got, testMsg ); return null; } );
    con.got( ( err, got ) => test.identical( got, null ) );

    test.identical( con.competitorsEarlyGet().length, 0 );
    test.identical( con.resourcesGet().length, 0 );
    return null;
  })

  /* */

  .doThen( function()
  {
    test.case = 'single err in give sequence, and single taker : attached taker after value resolved';

    var con = new _.Consequence();
    con.error( testMsg );
    con.ifNoErrorThen( ( got ) => { test.identical( 0, 1 ); return null; });
    con.got( ( err, got ) => test.identical( err, testMsg ) );

    test.identical( con.competitorsEarlyGet().length, 0 );
    test.identical( con.resourcesGet().length, 0 );
    return null;
  })

  /* */

  .doThen( function()
  {
    test.case = 'test ifNoErrorThen in chain, regular resource is given before error';

    var con = new _.Consequence();
    con.give( testMsg );
    con.give( testMsg );
    con.error( testMsg );

    con.ifNoErrorThen( ( got ) => { test.identical( got, testMsg ); return null; });
    con.ifNoErrorThen( ( got ) => { test.identical( got, testMsg ); return null; });

    test.identical( con.resourcesGet().length, 3 );
    test.identical( con.resourcesGet()[ 0 ].error, testMsg );
    test.identical( con.resourcesGet()[ 1 ], { error : undefined, argument : null } );
    test.identical( con.resourcesGet()[ 2 ], { error : undefined, argument : null } );
    test.identical( con.competitorsEarlyGet().length, 0 );
    return null;
  })

  /* */

  .doThen( function()
  {
    test.case = 'test ifNoErrorThen in chain, regular resource is given after error';

    var con = new _.Consequence();
    con.error( testMsg );
    con.give( testMsg );
    con.give( testMsg );

    con.ifNoErrorThen( ( got ) => { test.identical( 0, 1 ); return null; });
    con.ifNoErrorThen( ( got ) => { test.identical( 0, 1 ); return null; });

    test.identical( con.resourcesGet().length, 3 );
    test.identical( con.resourcesGet()[ 0 ].error, testMsg );
    test.identical( con.resourcesGet()[ 1 ], { error : undefined, argument : testMsg } );
    test.identical( con.resourcesGet()[ 2 ], { error : undefined, argument : testMsg } );
    test.identical( con.competitorsEarlyGet().length, 0 );
    return null;
  })

  /* */

  .doThen( function()
  {
    test.case = 'test ifNoErrorThen in chain serveral resources';

    var con = new _.Consequence();
    con.give( testMsg );
    con.give( testMsg );

    con.ifNoErrorThen( ( got ) => { test.identical( got, testMsg ); return null; });
    con.ifNoErrorThen( ( got ) => { test.identical( got, testMsg ); return null; });

    test.identical( con.resourcesGet().length, 2 );
    test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : null } );
    test.identical( con.resourcesGet()[ 1 ], { error : undefined, argument : null } );
    test.identical( con.competitorsEarlyGet().length, 0 );
    return null;
  })

   /* */

  .doThen( function()
  {
    if( !Config.debug )
    return;

    test.case = 'missed arguments';

    var con = _.Consequence();

    test.shouldThrowError( function()
    {
      con.ifNoErrorThen();
    });
    return null;
  })

  return testCon;
}

//

// function timeOutThen( test )
// {

//   var testCheck1 =

//     {
//       givSequence : [ 5 ],
//       got :
//       {
//         gotSequence :
//         [
//           { err : undefined, value : 5, takerId : 'taker1' }
//         ],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//           [
//             { err : undefined, value : 5, takerId : 'taker1' }
//           ],
//         throwErr : false
//       }
//     },
//     testCheck2 =
//     {
//       givSequence :
//         [
//           'err msg'
//         ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//           [ ],
//         throwErr : false
//       }
//     },
//     testCheck3 =
//     {
//       givSequence : [ 5, 3,  4 ],
//       got :
//       {
//         gotSequence : [],
//         throwErr : false
//       },
//       expected :
//       {
//         gotSequence :
//           [
//             { err : undefined, value : 4, takerId : 'taker3' },
//             { err : undefined, value : 3, takerId : 'taker2' },
//           ],
//         throwErr : false
//       }
//     };


//   /* common wConsequence corespondent tests. */

//   test.case = 'single value in give sequence, and single taker : attached taker after value resolved';
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//     }

//     var con = _.Consequence();
//     con.give( givSequence.shift() );
//     try
//     {
//       con.timeOutThen( 0, testTaker1 );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck1 );

//   /**/

//   test.case = 'single err in give sequence, and single taker : attached taker after value resolved';
//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//     }

//     var con = _.Consequence();
//     try
//     {
//       con.error( givSequence.shift() );
//       con.timeOutThen( 0, testTaker1 );
//     }
//     catch( err )
//     {
//       got.throwErr = !! err;
//     }
//     test.identical( got, expected );
//   } )( testCheck2 );

//   /**/

//   test.case = 'test timeOutThen in chain';

//   ( function( { givSequence, got, expected }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       got.gotSequence.push( { err, value, takerId } );
//       value++;
//       return value;
//     }

//     function testTaker2( err, value )
//     {
//       var takerId = 'taker2';
//       got.gotSequence.push( { err, value, takerId } );
//     }

//     function testTaker3( err, value )
//     {
//       var takerId = 'taker3';
//       got.gotSequence.push( { err, value, takerId } );
//     }

//     var con = _.Consequence();

//     for (var given of givSequence)
//       con.give( given );

//     con.timeOutThen( 20, testTaker1 );
//     con.timeOutThen( 10, testTaker2 );
//     con.got( testTaker3 )
//     .got( function() {
//       test.identical( got, expected );
//     } );



//   } )( testCheck3 );

//   if( Config.debug )
//   {
//     var conDeb1 = _.Consequence();

//     test.case = 'missed arguments';
//     test.shouldThrowError( function()
//     {
//       conDeb1.timeOutThen();
//     } );
//   }

// };

//

function timeOutThen( test )
{
  var testMsg = 'msg';
  var testCon = new _.Consequence().give( null )

  /* common wConsequence corespondent tests. */

  .doThen( function()
  {
    test.case = 'single value in give sequence, and single taker : attached taker after value resolved';

    var con = new _.Consequence();
    con.give( testMsg );
    con.timeOutThen( 0, ( err, got ) => { test.identical( got, testMsg ); return null; } );
    con.got( ( err, got ) => test.identical( got, null ) );

    return _.timeOut( 0, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
    })
  })

  /* */

  .doThen( function()
  {
    test.case = 'single err in give sequence, and single taker : attached taker after value resolved';

    var con = new _.Consequence();
    con.error( testMsg );
    con.timeOutThen( 0, ( err, got ) => { test.identical( err, testMsg ); return null; } );
    con.got( ( err, got ) => test.identical( got, null ) );

    return _.timeOut( 0, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
    })
  })

  /* */

  .doThen( function()
  {
    test.case = 'test timeOutThen in chain';
    var delay = 0;
    var con = new _.Consequence();
    con.give( testMsg );
    con.give( testMsg + 1 );
    con.give( testMsg + 2 );
    con.timeOutThen( delay, ( err, got ) => { test.identical( got, testMsg ); return null; } );
    con.timeOutThen( ++delay, ( err, got ) => { test.identical( got, testMsg + 1 ); return null; } );
    con.timeOutThen( ++delay, ( err, got ) => { test.identical( got, testMsg + 2 ); return null; } );

    return _.timeOut( delay, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 3 );
      con.resourcesGet()
      .every( ( msg ) => test.identical( msg, { error : undefined, argument : null } ) )
      return null;
    })
  })

  /* */

  .doThen( function()
  {
    if( !Config.debug )
    return;

    var con = _.Consequence();

    test.case = 'missed arguments';
    test.shouldThrowError( function()
    {
      con.timeOutThen();
    });
    return null;
  })

  return testCon;
}

//

function andThenRoutinesTakeFirst( test )
{
  var con = _.Consequence();
  var routines =
  [
    () => _.timeOut( 100, 0 ),
    () => _.timeOut( 100, 1 ),
    () => _.timeOut( 100, 2 ),
    () => _.timeOut( 100, 3 ),
    () => _.timeOut( 100, 4 ),
    () => _.timeOut( 100, 5 ),
    () => _.timeOut( 100, 6 ),
  ]

  con.take( null );
  con.andThen( routines );

  con.then( ( err, args ) =>
  {
    test.identical( err, undefined );
    test.identical( args, [ 0,1,2,3,4,5,6,null ] );
    if( err )
    throw err;
    return args;
  })

  return con;
}

//

function andThenRoutinesTakeLast( test )
{
  var con = _.Consequence();
  var routines =
  [
    () => _.timeOut( 100, 0 ),
    () => _.timeOut( 100, 1 ),
    () => _.timeOut( 100, 2 ),
    () => _.timeOut( 100, 3 ),
    () => _.timeOut( 100, 4 ),
    () => _.timeOut( 100, 5 ),
    () => _.timeOut( 100, 6 ),
  ]

  con.andThen( routines );

  con.then( ( err, args ) =>
  {
    test.identical( err, undefined );
    test.identical( args, [ 0,1,2,3,4,5,6,null ] );
    if( err )
    throw err;
    return args;
  })

  con.take( null );

  return con;
}

//

function andThenRoutinesDelayed( test )
{
  var con = _.Consequence();
  var routines =
  [
    () => _.timeOut( 100, 0 ),
    () => _.timeOut( 100, 1 ),
    () => _.timeOut( 100, 2 ),
    () => _.timeOut( 100, 3 ),
    () => _.timeOut( 100, 4 ),
    () => _.timeOut( 100, 5 ),
    () => _.timeOut( 100, 6 ),
  ]

  con.andThen( routines );

  con.then( ( err, args ) =>
  {
    test.identical( err, undefined );
    test.identical( args, [ 0,1,2,3,4,5,6,null ] );
    if( err )
    throw err;
    return args;
  })

  _.timeOut( 250, () =>
  {
    con.take( null );
    return true;
  });

  return con;
}

//

function andThen( test )
{
  var testMsg = 'msg';
  var testCon = new _.Consequence().give( null )

  /* */

  .doThen( function()
  {
    test.case = 'andThen waits only for first resource and return it back';
    var delay = 100;
    var mainCon = new _.Consequence();
    var con = new _.Consequence();

    mainCon.give( testMsg );

    mainCon.andThen( con );

    mainCon.doThen( function( err, got )
    {
      test.identical( got, [ delay, testMsg ] );
      test.identical( mainCon.resourcesGet().length, 0 );
      test.identical( con.resourcesGet(), [{ error : undefined, argument : delay }] );
      test.identical( con.competitorsEarlyGet().length, 0 );
      return null;
    });

    _.timeOut( delay, () => { con.give( delay );return null; });
    _.timeOut( delay * 2, () => { con.give( delay * 2 );return null; });

    return _.timeOut( delay * 2, function()
    {
      test.identical( con.resourcesGet().length, 2 );
      test.identical( con.resourcesGet()[ 1 ].argument, delay * 2 );
      return null;
    })
  })

  /* */

  .doThen( function()
  {
    test.case = 'andThen waits for first resource from consequence returned by routine call and returns resource back';
    var delay = 100;
    var mainCon = new _.Consequence();
    var con = new _.Consequence();

    mainCon.give( testMsg );

    mainCon.andThen( () => con );

    mainCon.doThen( function( err, got )
    {
      test.identical( got, [ delay, testMsg ] );
      test.identical( mainCon.resourcesGet().length, 0 );
      test.identical( con.resourcesGet().length, 1 );
      test.identical( con.resourcesGet()[ 0 ], { error : undefined, argument : delay } );
      test.identical( con.competitorsEarlyGet().length, 0 );
      return null;
    });

    _.timeOut( delay, () => { con.give( delay );return null; });
    _.timeOut( delay * 2, () => { con.give( delay * 2 );return null; });

    return _.timeOut( delay * 2, function()
    {
      test.identical( con.resourcesGet().length, 2 );
      test.identical( con.resourcesGet()[ 1 ], { error : undefined, argument : delay * 2 } );
      return null;
    })
  })

  /* */

  .doThen( function()
  {
    test.case = 'give back resources to several consequences, different delays';
    var delay = 100;
    var mainCon = new _.Consequence();
    var con1 = new _.Consequence();
    var con2 = new _.Consequence();
    var con3 = new _.Consequence();

    var srcs = [ con1, con2, con3 ];

    mainCon.give( testMsg );

    mainCon.andThen( srcs );

    mainCon.doThen( function( err, got )
    {
      test.identical( got, [ delay, delay * 2, testMsg + testMsg, testMsg ] )
      test.identical( mainCon.resourcesGet().length, 0 );

      test.identical( con1.resourcesGet(), [ { error : undefined, argument : delay } ]);
      test.identical( con1.competitorsEarlyGet().length, 0 );

      test.identical( con2.resourcesGet(), [ { error : undefined, argument : delay * 2 } ]);
      test.identical( con2.competitorsEarlyGet().length, 0 );

      test.identical( con3.resourcesGet(), [ { error : undefined, argument : testMsg + testMsg } ]);
      test.identical( con3.competitorsEarlyGet().length, 0 );

      return null;
    });

    _.timeOut( delay, () => { con1.give( delay );return null; });
    _.timeOut( delay * 2, () => { con2.give( delay * 2 );return null; });
    con3.give( testMsg + testMsg );

    return mainCon;
  })

  /* */

  .doThen( function()
  {
    test.case = 'each con gives several resources, order of provided consequence is important';
    var delay = 100;
    var mainCon = new _.Consequence();
    var con1 = new _.Consequence();
    var con2 = new _.Consequence();
    var con3 = new _.Consequence();

    var srcs = [ con3, con1, con2  ];

    mainCon.give( testMsg );

    mainCon.andThen( srcs );

    mainCon.doThen( function( err, got )
    {
      test.identical( got, [ 'con3', 'con1', 'con2', testMsg ] );
      test.identical( mainCon.resourcesGet().length, 0 );

      test.identical( con1.resourcesGet().length, 3 );
      test.identical( con1.competitorsEarlyGet().length, 0 );

      test.identical( con2.resourcesGet().length, 3 );
      test.identical( con2.competitorsEarlyGet().length, 0 );

      test.identical( con3.resourcesGet().length, 3 );
      test.identical( con3.competitorsEarlyGet().length, 0 );

      return null;
    });

    _.timeOut( delay, () =>
    {
      con1.give( 'con1' );
      con1.give( 'con1' );
      con1.give( 'con1' );
      return null;
    });

    _.timeOut( delay * 2, () =>
    {
      con2.give( 'con2' );
      con2.give( 'con2' );
      con2.give( 'con2' );
      return null;
    });

    _.timeOut( delay / 2, () =>
    {
      con3.give( 'con3' );
      con3.give( 'con3' );
      con3.give( 'con3' );
      return null;
    });

    return mainCon;
  })

  /* */

  .doThen( function()
  {
    test.case = 'one of provided cons waits for another one to resolve';
    var delay = 100;
    var mainCon = new _.Consequence();
    var con1 = new _.Consequence();
    var con2 = new _.Consequence();

    var srcs = [ con1, con2  ];

    con1.give( null );
    con1.doThen( () => con2 );
    con1.doThen( () => 'con1' );

    mainCon.give( testMsg );

    mainCon.andGot( srcs );

    mainCon.doThen( function( err, got )
    {
      test.identical( got, [ 'con1', 'con2', testMsg ] );

      test.identical( mainCon.resourcesGet().length, 0 );

      test.identical( con1.resourcesGet().length, 0 );
      test.identical( con1.competitorsEarlyGet().length, 0 );

      test.identical( con2.resourcesGet().length, 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

    _.timeOut( delay * 2, () => { con2.give( 'con2' ); return null;  } )

    return mainCon;
  })

  .doThen( function()
  {
    test.case =
    `consequence gives an error, only first error is taken into account
     other consequences are receiving their resources back`;

    var delay = 100;
    var mainCon = new _.Consequence();
    var con1 = new _.Consequence();
    var con2 = new _.Consequence();

    var srcs = [ con1, con2  ];

    mainCon.give( testMsg );

    mainCon.andThen( srcs );

    mainCon.doThen( function( err, got )
    {
      test.identical( err, 'con1' );
      test.identical( got, undefined );

      test.identical( mainCon.resourcesGet().length, 0 );

      test.identical( con1.resourcesGet().length, 1 );
      test.identical( con1.competitorsEarlyGet().length, 0 );

      test.identical( con2.resourcesGet().length, 1 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return null;
    });

    _.timeOut( delay, () => { con1.error( 'con1' );return null;  } )
    var t = _.timeOut( delay * 2, () => { con2.give( 'con2' );return null;  } )

    t.doThen( () =>
    {
      test.identical( con2.resourcesGet().length, 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return mainCon;
    })

    return t;
  })

  /* */

  .doThen( function()
  {
    test.case = 'passed consequence dont give any resource';
    var mainCon = new _.Consequence();
    var con = new _.Consequence();
    mainCon.give( null );
    mainCon.andThen( con );
    mainCon.doThen( () => { test.identical( 0, 1); return null; });
    test.identical( mainCon.resourcesGet().length, 0 );
    test.identical( mainCon.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 );
    return null;
  })

  /* */

  .doThen( function()
  {
    test.case = 'returned consequence dont give any resource';
    var mainCon = new _.Consequence();
    var con = new _.Consequence();
    mainCon.give( null );
    mainCon.andThen( () => con );
    mainCon.doThen( () => { test.identical( 0, 1); return null; });
    test.identical( mainCon.resourcesGet().length, 0 );
    test.identical( mainCon.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 );
    return null;
  })

  /* */

  .doThen( function()
  {
    test.case = 'one of srcs dont give any resource';
    var delay = 100;
    var mainCon = new _.Consequence();
    var con1 = new _.Consequence();
    var con2 = new _.Consequence();
    var con3 = new _.Consequence();

    var srcs = [ con1, con2, con3 ];

    mainCon.give( testMsg );

    mainCon.andThen( srcs );

    mainCon.doThen( () => { test.identical( 0, 1); return null; });

    _.timeOut( delay, () => { con1.give( delay );return null; });
    _.timeOut( delay * 2, () => { con2.give( delay * 2 );return null; });

    return _.timeOut( delay * 2, function()
    {
      test.identical( mainCon.resourcesGet().length, 0 );
      test.identical( mainCon.competitorsEarlyGet().length, 1 );

      test.identical( con1.resourcesGet().length, 0);
      test.identical( con2.resourcesGet().length, 0);
      test.identical( con3.resourcesGet().length, 0);
      return null;
    });

  })

  return testCon;
}

//

function andGot( test )
{
  var testMsg = 'msg';
  var testCon = new _.Consequence().give( null )

   /* */

  .doThen( function()
  {
    test.case = 'andGot waits only for first resource, dont return the resource';
    var delay = 100;
    var mainCon = new _.Consequence();
    var con = new _.Consequence();

    mainCon.give( testMsg );

    mainCon.andGot( con );

    mainCon.doThen( function( err, got )
    {
      test.identical( got, [ delay, testMsg ] )
      test.identical( mainCon.resourcesGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      return null;
    });

    _.timeOut( delay, () => { con.give( delay ) });
    _.timeOut( delay * 2, () => { con.give( delay * 2 ) });

    return _.timeOut( delay * 2, function()
    {
      test.identical( con.resourcesGet().length, 1 );
      test.identical( con.resourcesGet()[ 0 ].argument, delay * 2 );
      return null;
    })
  })

  /* */

  .doThen( function()
  {
    test.case = 'dont give resource back to single consequence returned from passed routine';
    var delay = 100;
    var mainCon = new _.Consequence();
    var con = new _.Consequence();

    mainCon.give( testMsg );

    mainCon.andGot( () => con );

    mainCon.doThen( function( err, got )
    {
      test.identical( got, [ delay, testMsg ] );
      test.identical( mainCon.resourcesGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con.competitorsEarlyGet().length, 0 );
      return null;
    });

    _.timeOut( delay, () => { con.give( delay ); return null; });

    return mainCon;
  })

  /* */

  .doThen( function()
  {
    test.case = 'dont give resources back to several consequences with different delays';
    var delay = 100;
    var mainCon = new _.Consequence();
    var con1 = new _.Consequence();
    var con2 = new _.Consequence();
    var con3 = new _.Consequence();

    var srcs = [ con1, con2, con3 ];

    mainCon.give( testMsg );

    mainCon.andGot( srcs );

    mainCon.doThen( function( err, got )
    {
      test.identical( got, [ delay, delay * 2, testMsg + testMsg, testMsg ] );

      test.identical( mainCon.resourcesGet().length, 0 );

      test.identical( con1.resourcesGet(), []);
      test.identical( con1.competitorsEarlyGet().length, 0 );

      test.identical( con2.resourcesGet(), []);
      test.identical( con2.competitorsEarlyGet().length, 0 );

      test.identical( con3.resourcesGet(), []);
      test.identical( con3.competitorsEarlyGet().length, 0 );

      return null;
    });

    _.timeOut( delay, () => { con1.give( delay ); return null; });
    _.timeOut( delay * 2, () => { con2.give( delay * 2 ); return null; });
    con3.give( testMsg + testMsg );

    return mainCon;
  })

  /* */

  .doThen( function()
  {
    test.case = 'each con gives several resources, order of provided consequence is important';
    var delay = 100;
    var mainCon = new _.Consequence();
    var con1 = new _.Consequence();
    var con2 = new _.Consequence();
    var con3 = new _.Consequence();

    var srcs = [ con3, con1, con2  ];

    mainCon.give( testMsg );

    mainCon.andGot( srcs );

    mainCon.doThen( function( err, got )
    {
      test.identical( got, [ 'con3', 'con1', 'con2', testMsg ] );

      test.identical( mainCon.resourcesGet().length, 0 );

      test.identical( con1.resourcesGet().length, 2 );
      test.identical( con1.competitorsEarlyGet().length, 0 );

      test.identical( con2.resourcesGet().length, 2 );
      test.identical( con2.competitorsEarlyGet().length, 0 );

      test.identical( con3.resourcesGet().length, 2 );
      test.identical( con3.competitorsEarlyGet().length, 0 );

      return null;
    });

    _.timeOut( delay, () =>
    {
      con1.give( 'con1' );
      con1.give( 'con1' );
      con1.give( 'con1' );
      return null;
    });

    _.timeOut( delay * 2, () =>
    {
      con2.give( 'con2' );
      con2.give( 'con2' );
      con2.give( 'con2' );
      return null;
    });

    _.timeOut( delay / 2, () =>
    {
      con3.give( 'con3' );
      con3.give( 'con3' );
      con3.give( 'con3' );
      return null;
    });

    return mainCon;
  })

  /* */

  .doThen( function()
  {
    test.case = 'one of provided cons waits for another one to resolve';
    var delay = 100;
    var mainCon = new _.Consequence();
    var con1 = new _.Consequence();
    var con2 = new _.Consequence();

    var srcs = [ con1, con2  ];

    con1.give( null );
    con1.doThen( () => con2 );
    con1.doThen( () => 'con1' );

    mainCon.give( testMsg );

    mainCon.andGot( srcs );

    mainCon.doThen( function( err, got )
    {
      test.identical( got, [ 'con1', 'con2', testMsg ] );

      test.identical( mainCon.resourcesGet().length, 0 );

      test.identical( con1.resourcesGet().length, 0 );
      test.identical( con1.competitorsEarlyGet().length, 0 );

      test.identical( con2.resourcesGet().length, 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );

      return null;
    });

    _.timeOut( delay * 2, () => { con2.give( 'con2' ); return null; } )

    return mainCon;
  })

  .doThen( function()
  {
    test.case = 'consequence gives an error, only first error is taken into account';

    var delay = 100;
    var mainCon = new _.Consequence();
    var con1 = new _.Consequence();
    var con2 = new _.Consequence();

    var srcs = [ con1, con2  ];

    mainCon.give( testMsg );

    mainCon.andGot( srcs );

    mainCon.doThen( function( err, got )
    {
      test.identical( err, 'con1' );
      test.identical( got, undefined );

      test.identical( mainCon.resourcesGet().length, 0 );

      test.identical( con1.resourcesGet().length, 0 );
      test.identical( con1.competitorsEarlyGet().length, 0 );

      test.identical( con2.resourcesGet().length, 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );

      return null;
    });

    _.timeOut( delay, () => { con1.error( 'con1' );return null;  } )
    var t = _.timeOut( delay * 2, () => { con2.give( 'con2' );return null;  } )

    t.doThen( () =>
    {
      test.identical( con2.resourcesGet().length, 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      return mainCon;
    })

    return t;
  })

  /* */

  .doThen( function()
  {
    test.case = 'passed consequence dont give any resource';
    var mainCon = new _.Consequence();
    var con = new _.Consequence();
    mainCon.give( null );
    mainCon.andGot( con );
    mainCon.doThen( () => test.identical( 0, 1 ) );
    test.identical( mainCon.resourcesGet().length, 0 );
    test.identical( mainCon.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 );
    return null;
  })

  /* */

  .doThen( function()
  {
    test.case = 'returned consequence dont give any resource';
    var mainCon = new _.Consequence();
    var con = new _.Consequence();
    mainCon.give( null );
    mainCon.andGot( () => con );
    mainCon.doThen( () => test.identical( 0, 1 ) );
    test.identical( mainCon.resourcesGet().length, 0 );
    test.identical( mainCon.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 );
    return null;
  })

  /* */

  .doThen( function()
  {
    test.case = 'one of srcs dont give any resource';
    var delay = 100;
    var mainCon = new _.Consequence();
    var con1 = new _.Consequence();
    var con2 = new _.Consequence();
    var con3 = new _.Consequence();

    var srcs = [ con1, con2, con3 ];

    mainCon.give( testMsg );

    mainCon.andGot( srcs );

    mainCon.doThen( () => { test.identical( 0, 1);return null; });

    _.timeOut( delay, () => { con1.give( delay ); return null; });
    _.timeOut( delay * 2, () => { con2.give( delay * 2 ); return null; });

    return _.timeOut( delay * 2, function()
    {
      test.identical( mainCon.resourcesGet().length, 0 );
      test.identical( mainCon.competitorsEarlyGet().length, 1 );

      test.identical( con1.resourcesGet().length, 0);
      test.identical( con2.resourcesGet().length, 0);
      test.identical( con3.resourcesGet().length, 0);
      return null;
    });

  })

  return testCon;
}

//

function _and( test )
{
  var testMsg = 'msg';
  var delay = 500;
  var testCon = new _.Consequence().give( null )

  /* common wConsequence corespondent tests. */

  .doThen( function()
  {
    test.case = 'give back resources to src consequences';

    var mainCon = new _.Consequence();
    var con1 = new _.Consequence();
    var con2 = new _.Consequence();

    mainCon.give( testMsg );

    mainCon._and( [ con1, con2 ], true );

    con1.got( ( err, got ) => { test.identical( got, delay ); return null; });
    con2.got( ( err, got ) => { test.identical( got, delay * 2 ); return null; });

    mainCon.doThen( function( err, got )
    {
      //at that moment all resources from srcs are processed
      test.identical( con1.resourcesGet().length, 0 );
      test.identical( con1.competitorsEarlyGet().length, 0 );
      test.identical( con2.resourcesGet().length, 0 );
      test.identical( con2.competitorsEarlyGet().length, 0 );
      test.identical( got, [ delay, delay * 2, testMsg ] );
      return null;
    });

    _.timeOut( delay, () => { con1.give( delay );return null; } );
    _.timeOut( delay * 2, () => { con2.give( delay * 2 );return null; } );

    return mainCon;
  })

  /* */

   .doThen( function()
  {
    test.case = 'dont give back resources to src consequences';

    var mainCon = new _.Consequence();
    var con1 = new _.Consequence();
    var con2 = new _.Consequence();

    mainCon.give( testMsg );

    mainCon._and( [ con1, con2 ], false );

    con1.got( ( err, got ) => { test.identical( 0, 1 ); return null; });
    con2.got( ( err, got ) => { test.identical( 0, 1 ); return null; });

    mainCon.doThen( function( err, got )
    {
      /* no resources returned back to srcs, their competitors must not be invoked */
      test.identical( con1.resourcesGet().length, 0 );
      test.identical( con1.competitorsEarlyGet().length, 1 );
      test.identical( con2.resourcesGet().length, 0 );
      test.identical( con2.competitorsEarlyGet().length, 1 );
      test.identical( got, [ delay, delay * 2, testMsg ] );
      return null;
    });

    _.timeOut( delay, () => { con1.give( delay ); return null; });
    _.timeOut( delay * 2, () => { con2.give( delay * 2 ); return null; });

    return mainCon;
  })

  return testCon;
}

//

function inter( test )
{

  test.case = 'got';

  var con1 = new _.Consequence().take( 1 );
  var con2 = new _.Consequence();

  con1.got( con2 );

  test.identical( con1._resource.length, 0 );
  test.identical( con1._competitorEarly.length, 0 );
  test.identical( con1._competitorLate.length, 0 );

  test.identical( con2._resource.length, 1 );
  test.identical( con2._competitorEarly.length, 0 );
  test.identical( con2._competitorLate.length, 0 );

  /* */

  test.case = 'done';

  var con1 = new _.Consequence().take( 1 );
  var con2 = new _.Consequence();

  con1.done( con2 );

  test.identical( con1._resource.length, 0 );
  test.identical( con1._competitorEarly.length, 0 );
  test.identical( con1._competitorLate.length, 0 );

  test.identical( con2._resource.length, 1 );
  test.identical( con2._competitorEarly.length, 0 );
  test.identical( con2._competitorLate.length, 0 );

  /* */

  test.case = 'then';

  var con1 = new _.Consequence().take( 1 );
  var con2 = new _.Consequence();

  con1.then( con2 );

  test.identical( con1._resource.length, 1 );
  test.identical( con1._competitorEarly.length, 0 );
  test.identical( con1._competitorLate.length, 0 );

  test.identical( con2._resource.length, 1 );
  test.identical( con2._competitorEarly.length, 0 );
  test.identical( con2._competitorLate.length, 0 );

  /* */

  test.case = 'doThen';

  var con1 = new _.Consequence().take( 1 );
  var con2 = new _.Consequence();

  con1.doThen( con2 );

  test.identical( con1._resource.length, 1 );
  test.identical( con1._competitorEarly.length, 0 );
  test.identical( con1._competitorLate.length, 0 );

  test.identical( con2._resource.length, 1 );
  test.identical( con2._competitorEarly.length, 0 );
  test.identical( con2._competitorLate.length, 0 );

  /* */

  test.case = 'take';

  var con1 = new _.Consequence().take( 1 );
  var con2 = new _.Consequence();

  con2.take( con1 );

  test.identical( con1._resource.length, 0 );
  test.identical( con1._competitorEarly.length, 0 );
  test.identical( con1._competitorLate.length, 0 );

  test.identical( con2._resource.length, 1 );
  test.identical( con2._competitorEarly.length, 0 );
  test.identical( con2._competitorLate.length, 0 );

}

//

function concurrentTakeExperiment( test )
{
  var tc = new _.Consequence().take( null );

  /* - */

  tc
  .ifNoErrorThen( () =>
  {
    debugger;
    var r = trivialSample();
    test.identical( r, 0 );
    return r;
  })
  .ifNoErrorThen( () =>
  {
    debugger;
    var r = putSample();
    test.identical( r, [ 0,1 ] );
    return r;
  })
  .ifNoErrorThen( () =>
  {
    var c = asyncSample();
    test.is( _.consequenceIs( c ) );
    c.doThen( ( err, arg ) =>
    {
      test.is( err === undefined );
      test.identical( arg, [ 0,1,2 ] );
      if( err )
      throw err;
      return arg;
    });
    return c;
  })

  return tc;

  /* */

  function trivialSample()
  {
    var con = new _.Consequence();
    var result = [];
    var array =
    [
      () => { console.log( 'sync0' ); return 0; },
      () => { console.log( 'sync1' ); return 1; },
    ]

    for( var a = 0 ; a < array.length ; a++ )
    con.got( 1 ).take( array[ a ]() );
    con.take( 0 );

    return con.toResourceMaybe();
  }

  /* */

  function putSample()
  {
    var result = [];
    var con = new _.Consequence();
    var array =
    [
      () => { return 0; },
      () => { return 1; },
    ]

    for( var a = 0 ; a < array.length ; a++ )
    _.after( array[ a ]() ).putThen( result, a ).participate( con );
    con.wait().take( result );

    return con.toResourceMaybe();
  }

  /* */

  function asyncSample()
  {
    var result = [];
    var con = new _.Consequence();
    var array =
    [
      () => { return 0; },
      () => { return timeOut( 100, 1 ); },
      () => { return 2; },
    ]

    for( var a = 0 ; a < array.length ; a++ )
    _.after( array[ a ]() ).putThen( result, a ).participate( con );
    con.wait().take( result );

    return con.toResourceMaybe();
  }

  /* */

  function timeOut( time, arg )
  {
    return _.timeOut( time, arg ).doThen( function( err, arg )
    {
      debugger;
      if( err )
      throw err;
      return arg;
    });
  }

}

concurrentTakeExperiment.timeOut = 10000;
concurrentTakeExperiment.experimental = 0;

//

// function _onceGot( test )
// {

//   var conseqTester = _.Consequence(); // for correct testing async aspects of wConsequence

//   var testChecks =
//     [
//       {
//         givSequence: [ 5 ],
//         gotSequence: [],
//         expectedSequence:
//         [
//          { err: undefined, value: 5, takerId: 'taker1' }
//         ],
//       },
//       {
//         givSequence: [
//           'err msg'
//         ],
//         gotSequence: [],
//         expectedSequence:
//         [
//           { err: 'err msg', value: void 0, takerId: 'taker1' }
//         ]
//       },
//       {
//         givSequence: [ 5, 4 ],
//         gotSequence: [],
//         expectedSequence:
//           [
//             { err: undefined, value: 5, takerId: 'taker1' },
//             { err: undefined, value: 4, takerId: 'taker2' }
//           ],
//       },
//       {
//         givSequence: [ 5, 4, 6 ],
//         gotSequence: [],
//         expectedSequence:
//         [
//           { err: undefined, value: 5, takerId: 'taker1' },
//           { err: undefined, value: 4, takerId: 'taker1' },
//           { err: undefined, value: 6, takerId: 'taker2' }
//         ],
//       },
//       {
//         givSequence: [ 5, 4, 6 ],
//         gotSequence: [],
//         expectedSequence:
//         [
//           { err: undefined, value: 5, takerId: 'taker1' },
//           { err: undefined, value: 4, takerId: 'taker2' },
//         ],
//       },
//     ];

//   /* common wConsequence goter tests. */

//   test.case = 'single value in give sequence, and single taker: attached taker after value resolved';
//   ( function( { givSequence, gotSequence, expectedSequence }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       gotSequence.push( { err, value, takerId } );
//     }

//     var con = _.Consequence();
//     con.give( givSequence.shift() );
//     con._onceGot( testTaker1 );
//     test.identical( gotSequence, expectedSequence );
//   } )( testChecks[ 0 ] );

//   /**/

//   test.case = 'single err in give sequence, and single taker: attached taker after value resolved';
//   ( function( { givSequence, gotSequence, expectedSequence }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       gotSequence.push( { err, value, takerId } );
//     }

//     var con = _.Consequence();
//     con.error( givSequence.shift() );
//     con._onceGot( testTaker1 );
//     test.identical( gotSequence, expectedSequence );
//   } )( testChecks[ 1 ] );

//   /**/

//   test.case = 'test _onceGot in chain';

//   ( function( { givSequence, gotSequence, expectedSequence }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       gotSequence.push( { err, value, takerId } );
//       value++;
//       return value;
//     }

//     function testTaker2( err, value )
//     {
//       var takerId = 'taker2';
//       gotSequence.push( { err, value, takerId } );
//     }

//     var con = _.Consequence();
//     for (var given of givSequence)
//     con.give( given );

//     con._onceGot( testTaker1 );
//     con._onceGot( testTaker2 );
//     test.identical( gotSequence, expectedSequence );
//   } )( testChecks[ 2 ] );

//   /* test particular _onceGot features test. */

//   test.case = 'several takers with same name: appending after given values are resolved';
//   ( function( { givSequence, gotSequence, expectedSequence }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       gotSequence.push( { err, value, takerId } );
//     }

//     function testTaker2( err, value )
//     {
//       var takerId = 'taker2';
//       gotSequence.push( { err, value, takerId } );
//     }

//     var con = _.Consequence();

//     for( var given of givSequence ) // pass all values in givSequence to consequenced
//     {
//       con.give( given );
//     }

//     con._onceGot( testTaker1 );
//     con._onceGot( testTaker1 );
//     con._onceGot( testTaker2 );
//     test.identical( gotSequence, expectedSequence );
//   } )( testChecks[ 3 ] );

//   /**/

//   test.case = 'several takers with same name: appending before given values are resolved';
//   ( function( { givSequence, gotSequence, expectedSequence }  )
//   {
//     function testTaker1( err, value )
//     {
//       var takerId = 'taker1';
//       gotSequence.push( { err, value, takerId } );
//     }

//     function testTaker2( err, value )
//     {
//       var takerId = 'taker2';
//       gotSequence.push( { err, value, takerId } );
//     }

//     var con = new _.Consequence();
//     var testCon = new _.Consequence().give( null );

//     con._onceGot( testTaker1 );
//     con._onceGot( testTaker1 );
//     con._onceGot( testTaker2 );

//     for( var given of givSequence ) // pass all values in givSequence to consequenced
//     {
//       testCon.doThen( () => con.give( given ) );
//     }

//     testCon.doThen( () => test.identical( gotSequence, expectedSequence ) );
//   } )( testChecks[ 4 ] );

//   /**/

//   if( Config.debug )
//   {
//     var conDeb1 = _.Consequence();

//     test.case = 'try to pass as parameter anonymous function';
//     test.shouldThrowError( function()
//     {
//       conDeb1._onceGot( function( err, val) { logger.log( 'i am anonymous' ); } );
//     });

//     var conDeb2 = _.Consequence();

//     test.case = 'try to pass as parameter anonymous function(defined in expression)';

//     function testHandler( err, val) { logger.log( 'i am anonymous' ); }
//     test.shouldThrowError( function()
//     {
//       conDeb2._onceGot( testHandler );
//     } );
//   }

//   conseqTester.give( null );
//   return conseqTester;
// }

//

function _onceGot( test )
{
  var testMsg = 'msg';
  var testCon = new _.Consequence().give( null )

  /* common wConsequence goter tests. */

  .doThen( function()
  {
    test.case = 'single value in give sequence, and single taker: attached taker after value resolved';
    function competitor( err, got )
    {
      test.identical( got, testMsg );
      test.identical( err, undefined );
    }
    var con = new _.Consequence();
    con.give( testMsg );
    con._onceGot( competitor );
  })

  /* */

  .doThen( function()
  {
    test.case = 'single err in give sequence, and single taker: attached taker after value resolved';

    function competitor( err, got )
    {
      test.identical( err, testMsg );
      test.identical( got, undefined );
    }
    var con = new _.Consequence();
    con.error( testMsg );
    con._onceGot( competitor );
  })

  /* */

  .doThen( function()
  {
    test.case = 'test _onceGot in chain';

    function competitor1( err, got )
    {
      test.identical( got, testMsg + 1 );
      return testMsg + 3;
    }
    function competitor2( err, got )
    {
      test.identical( got, testMsg + 2 );
    }
    var con = new _.Consequence();
    con.give( testMsg + 1 );
    con.give( testMsg + 2 );
    con._onceGot( competitor1 );
    con._onceGot( competitor2 );
  })

  /* test particular _onceGot features test. */

  .doThen( function()
  {
    test.case = 'several takers with same name: appending after given values are resolved';
    var competitor1Count = 0;
    var competitor2Count = 0;
    function competitor1( err, got )
    {
      test.identical( got, testMsg );
      competitor1Count++;
    }
    function competitor2( err, got )
    {
      test.identical( got, testMsg );
      competitor2Count++;
    }
    var con = new _.Consequence();

    con.give( testMsg );
    con.give( testMsg );
    con.give( testMsg );
    con._onceGot( competitor1 );
    con._onceGot( competitor1 );
    con._onceGot( competitor2 );

    test.identical( competitor1Count, 2 );
    test.identical( competitor2Count, 1 );
  })

  /* */

  .doThen( function()
  {
    test.case = 'several takers with same name: appending before given values are resolved';
    var competitor1Count = 0;
    var competitor2Count = 0;
    function competitor1( err, got )
    {
      test.identical( got, testMsg );
      competitor1Count++;
    }
    function competitor2( err, got )
    {
      test.identical( got, testMsg );
      competitor2Count++;
    }
    var con = new _.Consequence();

    con._onceGot( competitor1 );
    con._onceGot( competitor1 );
    con._onceGot( competitor2 );

    con.give( testMsg );
    con.give( testMsg );
    con.give( testMsg );

    test.identical( competitor1Count, 1 );
    test.identical( competitor2Count, 1 );
  })

  /* */

  .doThen( function()
  {
    if( !Config.debug )
    return;

    var con = new _.Consequence();

    test.case = 'try to pass as parameter anonymous function';
    test.shouldThrowError( function()
    {
      con._onceGot( function( err, val) { logger.log( 'i am anonymous' ); } );
    });

    /* */

    test.case = 'try to pass as parameter anonymous function(defined in expression)';
    function testHandler( err, val ) { logger.log( 'i am anonymous' ); }
    test.shouldThrowError( function()
    {
      con._onceGot( testHandler );
    });
  })

  return testCon;
}

//

function _onceThen( test )
{
  var testMsg = 'msg';
  var testCon = new _.Consequence().give( null )

  /* common wConsequence corespondent tests. */

  .doThen( function()
  {
    test.case = 'single value in give sequence, and single taker: attached taker after value resolved';
    function competitor( err, got )
    {
      test.identical( got, testMsg );
      test.identical( err, undefined );
      return got;
    }
    var con = new _.Consequence();
    con.give( testMsg );
    con._onceThen( competitor );
    con.got( ( err, got ) => test.identical( got, testMsg ) );
  })

  /* */

  .doThen( function()
  {
    test.case = 'single err in give sequence, and single taker: attached taker after value resolved';

    function competitor( err, got )
    {
      test.identical( err, testMsg );
      test.identical( got, undefined );
      return err;
    }
    var con = new _.Consequence();
    con.error( testMsg );
    con._onceThen( competitor );
    con.got( ( err, got ) => test.identical( got, testMsg ) );
  })

  /* */

  .doThen( function()
  {
    test.case = 'test _onceThen in chain';

    function competitor1( err, got )
    {
      test.identical( got, testMsg );
      return testMsg + 1;
    }
    function competitor2( err, got )
    {
      test.identical( got, testMsg );
      return testMsg + 2;
    }
    var con = new _.Consequence();
    con.give( testMsg );
    con.give( testMsg );
    con._onceThen( competitor1 );
    con._onceThen( competitor2 );
    con.got( ( err, got ) => test.identical( got, testMsg + 1 ) );
    con.got( ( err, got ) => test.identical( got, testMsg + 2 ) );
  })

  /* test particular _onceGot features test. */

  .doThen( function()
  {
    test.case = 'added several corespondents with same name';
    var competitor1Count = 0;
    var competitor2Count = 0;
    function competitor1( err, got )
    {
      test.identical( got, testMsg );
      competitor1Count++;
      return got;
    }
    function competitor2( err, got )
    {
      test.identical( got, testMsg );
      competitor2Count++;
      return got;
    }
    var con = new _.Consequence();

    con._onceThen( competitor1 );
    con._onceThen( competitor1 );
    con._onceThen( competitor2 );

    test.identical( con.competitorsEarlyGet().length, 2 );

    con.give( testMsg );

    test.identical( competitor1Count, 1 );
    test.identical( competitor2Count, 1 );

    test.identical( con.resourcesGet().length, 1 );
    test.identical( con.competitorsEarlyGet().length, 0 );
    test.identical( con.resourcesGet()[ 0 ].argument, testMsg );

  })

  /* */

  .doThen( function()
  {
    if( !Config.debug )
    return;

    var con = new _.Consequence();

    test.case = 'try to pass as parameter anonymous function';
    test.shouldThrowError( function()
    {
      con._onceThen( function( err, val) { logger.log( 'i am anonymous' ); } );
    });

    /* */

    test.case = 'try to pass as parameter anonymous function(defined in expression)';
    function testHandler( err, val) { logger.log( 'i am anonymous' ); }
    test.shouldThrowError( function()
    {
      con._onceThen( testHandler );
    });
  })

  return testCon;
}

//

function first( test )
{
  var c = this;
  var amode = _.Consequence.asyncModeGet();
  var testMsg = 'msg';
  var testCon = new _.Consequence().give( null )

  /**/

  .doThen( function()
  {
    test.case = 'simplest, empty routine';
    var con = new _.Consequence();
    con.first( () => null );
    con.give( testMsg );
    con.doThen( function( err, got )
    {
      test.identical( got, null );
      test.identical( con.resourcesGet(), [{ error : undefined, argument : testMsg }] );
      return null;
    })
    return con;
  })

  /**/

  .doThen( function()
  {
    test.case = 'routine returns something';
    var con = new _.Consequence();
    con.first( () => testMsg );
    con.give( testMsg + 2 );
    con.doThen( function( err, got )
    {
      test.identical( got, testMsg );
      test.identical( con.resourcesGet(), [{ error : undefined, argument : testMsg + 2 }] );
      return null;
    })
    return con;
  })

  /**/

  .doThen( function()
  {
    test.case = 'routine throws error';
    var con = new _.Consequence();
    con.first( () => { throw testMsg });
    con.doThen( function( err, got )
    {
      test.is( _.errIs( err ) );
      test.identical( got, undefined );
      test.identical( con.resourcesGet(),[] );
      return null;
    })
    return con;
  })

  /**/

  .doThen( function()
  {
    test.case = 'routine returns consequence with resource';
    var con = new _.Consequence();
    con.first( () => new _.Consequence().give( testMsg ));
    con.doThen( function( err, got )
    {
      test.identical( err, undefined );
      test.identical( got, testMsg );
      test.identical( con.resourcesGet(),[] );
      return null;
    })
    return con;
  })

  /**/

  .doThen( function()
  {
    test.case = 'routine returns consequence with err resource';
    var con = new _.Consequence();
    con.first( () => new _.Consequence().error( testMsg ));
    con.doThen( function( err, got )
    {
      test.identical( err, testMsg );
      test.identical( got, undefined );
      test.identical( con.resourcesGet(),[] );
      return null;
    })
    return con;
  })

  /**/

  .doThen( function()
  {
    test.case = 'routine returns consequence that gives resource with timeout';
    var con = new _.Consequence();
    var timeBefore = _.timeNow();
    con.first( () => _.timeOut( 250, () => null ));
    con.doThen( function( err, got )
    {
      var delay = _.timeNow() - timeBefore;
      var description = test.case = 'delay ' + delay;
      test.ge( delay, 250 - c.timeAccuracy );
      test.case = description;
      test.identical( err, undefined );
      test.identical( got, null );
      test.identical( con.resourcesGet(),[] );
      return null;
    })
    return con;
  })

  /**/

  .doThen( function()
  {
    test.case = 'passed consequence shares own resource';
    var con = new _.Consequence();
    var con2 = new _.Consequence().give( testMsg );
    con.first( con2 );
    con.doThen( function( err, got )
    {
      test.identical( err, undefined );
      test.identical( got, testMsg );
      test.identical( con.resourcesGet(),[] );
      test.identical( con2.resourcesGet(), [{ error : undefined, argument : testMsg }] );
      return null;
    })
    return con;
  })

  /**/

  .doThen( function()
  {
    test.case = 'passed consequence shares own resource with timeout';
    var con = new _.Consequence();
    var con2 = _.timeOut( 250, () => testMsg );
    var timeBefore = _.timeNow();
    con.first( con2 );
    con.doThen( function( err, got )
    {
      var delay = _.timeNow() - timeBefore;
      var description = test.case = 'delay ' + delay;
      test.ge( delay, 250 - c.timeAccuracy );
      test.case = description;
      test.identical( err, undefined );
      test.identical( got, testMsg );
      test.identical( con.resourcesGet(),[] );
      test.identical( con2.resourcesGet(),[{ error : undefined, argument : testMsg }] );
      return null;
    })
    return con;
  })

  /* Async taking, Sync giving */

  testCon.doThen( () => _.Consequence.asyncModeSet([ 1, 0 ]) )

   .doThen( function()
  {
    test.case = 'simplest, empty routine';
    var con = new _.Consequence();
    con.first( () => null );
    con.give( testMsg );
    con.got( function( err, got )
    {
      test.identical( got, null );
      test.identical( con.resourcesGet(), [{ error : undefined, argument : testMsg }] );
      return null;
    })

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 1 );
      return null;
    })
  })

  /**/

  .doThen( function()
  {
    test.case = 'routine returns something';
    var con = new _.Consequence();
    con.first( () => testMsg );
    con.give( testMsg + 2 );
    con.got( function( err, got )
    {
      test.identical( got, testMsg );
    })

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet(), [{ error : undefined, argument : testMsg + 2 }] );
      return null;
    })
  })

  /**/

  .doThen( function()
  {
    test.case = 'routine throws error';
    var con = new _.Consequence();
    con.first( () => { throw testMsg });
    con.got( function( err, got )
    {
      test.is( _.errIs( err ) );
      test.identical( got, undefined );
      test.identical( con.resourcesGet(),[] );
    })

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /**/

  .doThen( function()
  {
    test.case = 'routine returns consequence with resource';
    var con = new _.Consequence();
    con.first( () => new _.Consequence().give( testMsg ));
    con.got( function( err, got )
    {
      test.identical( err, undefined );
      test.identical( got, testMsg );
    })

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /**/

  .doThen( function()
  {
    test.case = 'routine returns consequence with err resource';
    var con = new _.Consequence();
    con.first( () => new _.Consequence().error( testMsg ));
    con.got( function( err, got )
    {
      test.identical( err, testMsg );
      test.identical( got, undefined );
      test.identical( con.resourcesGet(),[] );
    })
    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /**/

  .doThen( function()
  {
    test.case = 'routine returns consequence that gives resource with timeout';
    var con = new _.Consequence();
    var timeBefore = _.timeNow();
    con.first( () => _.timeOut( 250, () => null ));
    con.got( function( err, got )
    {
      var delay = _.timeNow() - timeBefore;
      var description = test.case = 'delay ' + delay;
      test.ge( delay, 250 - c.timeAccuracy );
      test.case = description;
      test.identical( err, undefined );
      test.identical( got, null );
      test.identical( con.resourcesGet(),[] );
    })
    return _.timeOut( 251, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /**/

  .doThen( function()
  {
    test.case = 'passed consequence shares own resource';
    var con = new _.Consequence();
    var con2 = new _.Consequence().give( testMsg );
    con.first( con2 );
    con.got( function( err, got )
    {
      test.identical( err, undefined );
      test.identical( got, testMsg );
      test.identical( con.resourcesGet(),[] );
      test.identical( con2.resourcesGet(), [{ error : undefined, argument : testMsg }] );
    })
    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /**/

  .doThen( function()
  {
    test.case = 'passed consequence shares own resource with timeout';
    var con = new _.Consequence();
    var con2 = _.timeOut( 250, () => testMsg );
    var timeBefore = _.timeNow();
    con.first( con2 );
    con.got( function( err, got )
    {
      var delay = _.timeNow() - timeBefore;
      var description = test.case = 'delay ' + delay;
      test.ge( delay, 250 - c.timeAccuracy );
      test.case = description;
      test.identical( err, undefined );
      test.identical( got, testMsg );
      test.identical( con.resourcesGet(),[] );
      test.identical( con2.resourcesGet(),[{ error : undefined, argument : testMsg }] );
    })
    return _.timeOut( 251, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /* Sync taking, Async giving */

  testCon.doThen( () => _.Consequence.asyncModeSet([ 0, 1 ]) )

   .doThen( function()
  {
    test.case = 'simplest, empty routine';
    var con = new _.Consequence();
    con.got( function( err, got )
    {
      test.identical( got, null );
    });
    con.first( () => null );

    con.give( testMsg );

    test.identical( con.resourcesGet().length, 2 );
    test.identical( con.competitorsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet(), [{ error : undefined, argument : testMsg }] );
      return null;
    })
  })

  /**/

  .doThen( function()
  {
    test.case = 'routine returns something';
    var con = new _.Consequence();
    con.got( function( err, got )
    {
      test.identical( got, testMsg );
    })
    con.first( () => testMsg );

    con.give( testMsg + 2 );

    test.identical( con.resourcesGet().length, 2 );
    test.identical( con.competitorsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet(), [{ error : undefined, argument : testMsg + 2 }] );
      return null;
    })
  })

  /**/

  .doThen( function()
  {
    test.case = 'routine throws error';
    var con = new _.Consequence();
    con.first( () => { throw testMsg });

    test.identical( con.resourcesGet().length, 0 );

    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 1 );
      con.got( function( err, got )
      {
        test.is( _.errIs( err ) );
        test.identical( got, undefined );
      });
    })
    .doThen( function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /**/

  .doThen( function()
  {
    test.case = 'routine returns consequence with resource';
    var con = new _.Consequence();
    con.first( () => new _.Consequence().give( testMsg ));

    test.identical( con.resourcesGet().length, 0 );

    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 1 );

      con.got( function( err, got )
      {
        test.identical( err, undefined );
        test.identical( got, testMsg );
      })
      return null;
    })
    .doThen( function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /**/

  .doThen( function()
  {
    test.case = 'routine returns consequence with err resource';
    var con = new _.Consequence();
    con.first( () => new _.Consequence().error( testMsg ));

    test.identical( con.resourcesGet().length, 0 );

    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 1 );

      con.got( function( err, got )
      {
        test.identical( err, testMsg );
        test.identical( got, undefined );
      })
      return null;
    })
    .doThen( function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /**/

  .doThen( function()
  {
    test.case = 'routine returns consequence that gives resource with timeout';
    var con = new _.Consequence();
    var timeBefore = _.timeNow();
    con.first( () => _.timeOut( 250, () => null ));

    test.identical( con.resourcesGet().length, 0 );

    return _.timeOut( 251, function()
    {
      test.identical( con.resourcesGet().length, 1 );

      con.got( function( err, got )
      {
        var delay = _.timeNow() - timeBefore;
        var description = test.case = 'delay ' + delay;
        test.ge( delay, 250 - c.timeAccuracy );
        test.case = description;
        test.identical( err, undefined );
        test.identical( got, null );
      })
      return null;
    })
    .doThen( function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /**/

  .doThen( function()
  {
    test.case = 'passed consequence shares own resource';
    var con = new _.Consequence();
    var con2 = new _.Consequence().give( testMsg );
    con.first( con2 );

    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 1 );

      con.got( function( err, got )
      {
        test.identical( err, undefined );
        test.identical( got, testMsg );
      })
      return null;
    })
    .doThen( function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con2.resourcesGet().length, 1 );
      return null;
    })
  })

  /**/

  .doThen( function()
  {
    test.case = 'passed consequence shares own resource with timeout';
    var con = new _.Consequence();
    var con2 = _.timeOut( 250, () => testMsg );
    var timeBefore = _.timeNow();
    con.first( con2 );

    return _.timeOut( 251, function()
    {
      test.identical( con.resourcesGet().length, 1 );

      con.got( function( err, got )
      {
        var delay = _.timeNow() - timeBefore;
        var description = test.case = 'delay ' + delay;
        test.ge( delay, 250 - c.timeAccuracy );
        test.case = description;
        test.identical( err, undefined );
        test.identical( got, testMsg );
      })
      return null;
    })
    .doThen( function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con2.resourcesGet().length, 1 );
      return null;
    })
  })

  /* Async taking, Async giving */

  testCon.doThen( () =>
  {
    _.Consequence.asyncModeSet([ 1, 1 ]);
    return null;
  })

   .doThen( function()
  {
    test.case = 'simplest, empty routine';
    var con = new _.Consequence();
    con.got( function( err, got )
    {
      test.identical( got, null );
    });
    con.first( () => null );
    con.give( testMsg );

    test.identical( con.resourcesGet().length, 2 );
    test.identical( con.competitorsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet(), [{ error : undefined, argument : testMsg }] );
      return null;
    })
  })

  /**/

  .doThen( function()
  {
    test.case = 'routine returns something';
    var con = new _.Consequence();
    con.got( function( err, got )
    {
      test.identical( got, testMsg );
    })
    con.first( () => testMsg );

    con.give( testMsg + 2 );

    test.identical( con.resourcesGet().length, 2 );
    test.identical( con.competitorsEarlyGet().length, 1 );

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet(), [{ error : undefined, argument : testMsg + 2 }] );
      return null;
    })
  })

  /**/

  .doThen( function()
  {
    test.case = 'routine throws error';
    var con = new _.Consequence();
    con.first( () => { throw testMsg });
    con.got( function( err, got )
    {
      test.is( _.errIs( err ) );
      test.identical( got, undefined );
    });

    test.identical( con.resourcesGet().length, 0 );

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /**/

  .doThen( function()
  {
    test.case = 'routine returns consequence with resource';
    var con = new _.Consequence();
    con.first( () => new _.Consequence().give( testMsg ));
    con.got( function( err, got )
    {
      test.identical( err, undefined );
      test.identical( got, testMsg );
    })
    test.identical( con.resourcesGet().length, 0 );

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /**/

  .doThen( function()
  {
    test.case = 'routine returns consequence with err resource';
    var con = new _.Consequence();
    con.first( () => new _.Consequence().error( testMsg ));
    con.got( function( err, got )
    {
      test.identical( err, testMsg );
      test.identical( got, undefined );
    })
    test.identical( con.resourcesGet().length, 0 );

    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /**/

  .doThen( function()
  {
    test.case = 'routine returns consequence that gives resource with timeout';
    var con = new _.Consequence();
    var timeBefore = _.timeNow();
    con.first( () => _.timeOut( 250, () => null ));
    con.got( function( err, got )
    {
      var delay = _.timeNow() - timeBefore;
      var description = test.case = 'delay ' + delay;
      test.ge( delay, 250 - c.timeAccuracy );
      test.case = description;
      test.identical( err, undefined );
      test.identical( got, null );
    })
    test.identical( con.resourcesGet().length, 0 );

    return _.timeOut( 251, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      return null;
    })
  })

  /**/

  .doThen( function()
  {
    test.case = 'passed consequence shares own resource';
    var con = new _.Consequence();
    var con2 = new _.Consequence().give( testMsg );
    con.first( con2 );
    con.got( function( err, got )
    {
      test.identical( err, undefined );
      test.identical( got, testMsg );
    })
    return _.timeOut( 1, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con2.resourcesGet().length, 1 );
      return null;
    })
  })

  /**/

  .doThen( function()
  {
    test.case = 'passed consequence shares own resource with timeout';
    var con = new _.Consequence();
    var con2 = _.timeOut( 250, () => testMsg );
    var timeBefore = _.timeNow();
    con.first( con2 );
    con.got( function( err, got )
    {
      var delay = _.timeNow() - timeBefore;
      var description = test.case = 'delay ' + delay;
      test.ge( delay, 250 - c.timeAccuracy );
      test.case = description;
      test.identical( err, undefined );
      test.identical( got, testMsg );
    })
    return _.timeOut( 251, function()
    {
      test.identical( con.competitorsEarlyGet().length, 0 );
      test.identical( con.resourcesGet().length, 0 );
      test.identical( con2.resourcesGet().length, 1 );
      return null;
    })
  });

  /* */

  testCon.doThen( () =>
  {
    _.Consequence.asyncModeSet( amode );
    return null;
  });

  return testCon;
}

first.timeOut = 20000;

//

function from( test )
{
  var testMsg = 'value';
  var testCon = new _.Consequence().give( null )

  /**/

  .doThen( function()
  {
    test.case = 'passing value';
    var con = _.Consequence.From( testMsg );
    test.identical( con.resourcesGet(), [ { error : undefined, argument : testMsg } ] );
    test.identical( con.competitorsEarlyGet(), [] );
    return con;
  })

  /**/

  .doThen( function()
  {
    test.case = 'passing an error';
    var err = _.err( testMsg );
    var con = _.Consequence.From( err );
    test.identical( con.resourcesGet(), [ { error : err, argument : undefined } ] );
    test.identical( con.competitorsEarlyGet(), [] );
    return con;
  })

  /**/

  .doThen( function()
  {
    test.case = 'passing consequence';
    var src = new _.Consequence().give( testMsg );
    var con = _.Consequence.From( src );
    test.identical( con, src );
    test.identical( con.resourcesGet(), [ { error : undefined, argument : testMsg } ] );
    test.identical( con.competitorsEarlyGet(), [] );
    return con;
  })

  /**/

  .doThen( function()
  {
    test.case = 'passing resolved promise';
    var src = Promise.resolve( testMsg );
    var con = _.Consequence.From( src );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet(), [ { error : undefined, argument : testMsg } ] );
      test.identical( con.competitorsEarlyGet(), [] );
      return null;
    })
  })

  /**/

  .doThen( function()
  {
    test.case = 'passing rejected promise';
    var src = Promise.reject( testMsg );
    var con = _.Consequence.From( src );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet(), [ { error : testMsg, argument : undefined } ] );
      test.identical( con.competitorsEarlyGet(), [] );
      return null;
    })
  })

  /**/

  .doThen( function()
  {
    wConsequence.prototype.asyncTaking = 0;
    wConsequence.prototype.asyncGiving = 1;
    return null;
  })

  /**/

  .doThen( function()
  {
    test.case = 'async giving passing value';
    var con = _.Consequence.From( testMsg );
    con.got( ( err, got ) => test.identical( got, testMsg ) )
    test.identical( con.resourcesGet(), [ { error : undefined, argument : testMsg } ] );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsEarlyGet(), [] );
      return null;
    })

    return con;
  })

  /**/

  .doThen( function()
  {
    test.case = 'passing an error';
    var src = _.err( testMsg );
    var con = _.Consequence.From( src );
    con.got( ( err, got ) => test.identical( err, src ) )
    test.identical( con.resourcesGet(), [ { error : src, argument : undefined } ] );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsEarlyGet(), [] );
      return null;
    })

    return con;
  })

  /**/

  .doThen( function()
  {
    test.case = 'passing consequence';
    var src = new _.Consequence().give( testMsg );
    var con = _.Consequence.From( src );
    con.got( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( src.resourcesGet(), [ { error : undefined, argument : testMsg } ] );
    test.identical( con, src );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsEarlyGet(), [] );
      return null;
    })

    return con;
  })

  /**/

  .doThen( function()
  {
    test.case = 'passing resolved promise';
    var src = Promise.resolve( testMsg );
    var con = _.Consequence.From( src );
    con.got( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( con.resourcesGet().length, 0 )
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 0 )
      test.identical( con.competitorsEarlyGet().length, 0 )
      return null;
    })
  })

  /**/

  .doThen( function()
  {
    test.case = 'passing rejected promise';
    var src = Promise.reject( testMsg );
    var con = _.Consequence.From( src );
    con.got( ( err, got ) => test.identical( err, testMsg ) );
    test.identical( con.resourcesGet().length, 0 )
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 0 )
      test.identical( con.competitorsEarlyGet().length, 0 )
      return null;
    })
  })

  /**/

  .doThen( function()
  {
    wConsequence.prototype.asyncTaking = 1;
    wConsequence.prototype.asyncGiving = 0;
    return null;
  })

  /**/

  .doThen( function()
  {
    test.case = 'async taking, passing value';
    var con = _.Consequence.From( testMsg );
    con.got( ( err, got ) => test.identical( got, testMsg ) )
    test.identical( con.resourcesGet(), [ { error : undefined, argument : testMsg } ] );
    test.identical( con.competitorsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsEarlyGet(), [] );
      return null;
    })

    return con;
  })

  /**/

  .doThen( function()
  {
    test.case = 'async taking,passing an error';
    var src = _.err( testMsg );
    var con = _.Consequence.From( src );
    con.got( ( err, got ) => test.identical( err, src ) )
    test.identical( con.resourcesGet(), [ { error : src, argument : undefined } ] );
    test.identical( con.competitorsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsEarlyGet(), [] );
      return null;
    })

    return con;
  })

  /**/

  .doThen( function()
  {
    test.case = 'async taking,passing consequence';
    var src = new _.Consequence().give( testMsg );
    var con = _.Consequence.From( src );
    con.got( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( src.resourcesGet(), [ { error : undefined, argument : testMsg } ] );
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con, src );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsEarlyGet(), [] );
      return null;
    })

    return con;
  })

  /**/

  .doThen( function()
  {
    test.case = 'async taking,passing resolved promise';
    var src = Promise.resolve( testMsg );
    var con = _.Consequence.From( src );
    con.got( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 )
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 0 )
      test.identical( con.competitorsEarlyGet().length, 0 )
      return null;
    })
  })

  /**/

  .doThen( function()
  {
    test.case = 'async taking,passing rejected promise';
    var src = Promise.reject( testMsg );
    var con = _.Consequence.From( src );
    con.got( ( err, got ) => test.identical( err, testMsg ) );
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 )
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 0 )
      test.identical( con.competitorsEarlyGet().length, 0 )
      return null;
    })
  })

  /**/

  .doThen( function()
  {
    wConsequence.prototype.asyncTaking = 1;
    wConsequence.prototype.asyncGiving = 1;
    return null;
  })

  /**/

  .doThen( function()
  {
    test.case = 'async, passing value';
    var con = _.Consequence.From( testMsg );
    con.got( ( err, got ) => test.identical( got, testMsg ) )
    test.identical( con.resourcesGet(), [ { error : undefined, argument : testMsg } ] );
    test.identical( con.competitorsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsEarlyGet(), [] );
      return null;
    })

    return con;
  })

  /**/

  .doThen( function()
  {
    test.case = 'async,passing an error';
    var src = _.err( testMsg );
    var con = _.Consequence.From( src );
    con.got( ( err, got ) => test.identical( err, src ) )
    test.identical( con.resourcesGet(), [ { error : src, argument : undefined } ] );
    test.identical( con.competitorsEarlyGet().length, 1 );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsEarlyGet(), [] );
      return null;
    })

    return con;
  })

  /**/

  .doThen( function()
  {
    test.case = 'async,passing consequence';
    var src = new _.Consequence().give( testMsg );
    var con = _.Consequence.From( src );
    con.got( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( src.resourcesGet(), [ { error : undefined, argument : testMsg } ] );
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con, src );
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet(), [] );
      test.identical( con.competitorsEarlyGet(), [] );
      return null;
    })

    return con;
  })

  /**/

  .doThen( function()
  {
    test.case = 'async,passing resolved promise';
    var src = Promise.resolve( testMsg );
    var con = _.Consequence.From( src );
    con.got( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 )
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 0 )
      test.identical( con.competitorsEarlyGet().length, 0 )
      return null;
    })
  })

  /**/

  .doThen( function()
  {
    test.case = 'async,passing rejected promise';
    var src = Promise.reject( testMsg );
    var con = _.Consequence.From( src );
    con.got( ( err, got ) => test.identical( err, testMsg ) );
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 )
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 0 )
      test.identical( con.competitorsEarlyGet().length, 0 )
      return null;
    })
  })

  /**/

  .doThen( function()
  {
    wConsequence.prototype.asyncTaking = 0;
    wConsequence.prototype.asyncGiving = 0;
    return null;
  })
  .doThen( function()
  {
    test.case = 'sync, resolved promise, timeout';
    var src = Promise.resolve( testMsg );
    var con = _.Consequence.From( src, 500 );
    con.got( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 )
    return _.timeOut( 1, function()
    {
      test.identical( con.resourcesGet().length, 0 )
      test.identical( con.competitorsEarlyGet().length, 0 )
      return null;
    })
  })

  /**/

  .doThen( function()
  {
    test.case = 'sync, promise resolved with timeout';
    var src = new Promise( ( resolve ) =>
    {
      setTimeout( () => resolve( testMsg ), 600 );
    })
    var con = _.Consequence.From( src, 500 );
    con.got( ( err, got ) => test.is( _.errIs( err ) ) );
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 )
    return _.timeOut( 600, function()
    {
      test.identical( con.resourcesGet().length, 0 )
      test.identical( con.competitorsEarlyGet().length, 0 )
      return null;
    })
  })

  /**/

  .doThen( function()
  {
    test.case = 'sync, timeout, src is a consequence';
    var con = new _.Consequence().give( testMsg );
    con = _.Consequence.From( con , 500 );
    con.got( ( err, got ) => test.identical( got, testMsg ) );
    test.identical( con.competitorsEarlyGet().length, 0 );
    test.identical( con.resourcesGet().length, 0 );
    return null;
  })

  /**/

  .doThen( function()
  {
    test.case = 'sync, timeout, src is a consequence';
    var con = _.timeOut( 600, () => testMsg );
    con = _.Consequence.From( con , 500 );
    con.got( ( err, got ) => test.is( _.errIs( err ) ) );
    test.identical( con.competitorsEarlyGet().length, 1 );
    test.identical( con.resourcesGet().length, 0 );
    return _.timeOut( 600, function()
    {
      test.identical( con.resourcesGet().length, 0 )
      test.identical( con.competitorsEarlyGet().length, 0 )
      return null;
    })
  })

  /**/

  .doThen( function()
  {
    wConsequence.prototype.asyncTaking = 0;
    wConsequence.prototype.asyncGiving = 0;
    return null;
  })

  return testCon;
}

//

function consequenceLike( test )
{
  test.case = 'check if entity is a consequenceLike';

  if( !_.consequenceLike )
  return test.identical( true,true );

  test.is( !_.consequenceLike() );
  test.is( !_.consequenceLike( {} ) );
  if( _.Consequence )
  {
    test.is( _.consequenceLike( new _.Consequence() ) );
    test.is( _.consequenceLike( _.Consequence() ) );
  }
  test.is( _.consequenceLike( Promise.resolve( 0 ) ) );

  var promise = new Promise( ( resolve, reject ) => { resolve( 0 ) } )
  test.is( _.consequenceLike( promise ) );
  test.is( _.consequenceLike( _.Consequence.From( promise ) ) );

}

// --
// declare
// --

var Self =
{

  name : 'Tools/base/Consequence',
  silencing : 1,
  // verbosity : 7,

  context :
  {
    timeAccuracy : 1,
  },

  tests :
  {

    simple,
    ordinarMessage,
    promiseGot,

    doThen,
    promiseThen,

    // _onceGot,
    // _onceThen,

    split,
    tap,

    ifNoErrorThen,
    ifErrorThen,

    timeOutThen,

    andThenRoutinesTakeFirst,
    andThenRoutinesTakeLast,
    andThenRoutinesDelayed,
    andThen,
    andGot,
    _and,

    inter,
    concurrentTakeExperiment,

    first,
    from,
    consequenceLike

  },

};

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();