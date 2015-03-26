const int size  = @SIZE;
const float iSize = .5/float(size);


uniform vec2 resolution;

uniform sampler2D t_oPos;
uniform sampler2D t_pos;
uniform sampler2D t_posRight;
uniform sampler2D t_posLeft;
uniform sampler2D t_posTop;
uniform sampler2D t_posBottom;
uniform sampler2D t_og;
uniform sampler2D t_audio;
uniform float dT;
uniform float timer;

uniform vec3 repelers[ size ];
uniform vec3 power[ size ];

uniform float repulsionPower;
uniform float repulsionRadius;
uniform float dampening;
uniform float springLength;
uniform float springMultiplier;

varying vec2 vUv;

$springForce

vec3 getSurrounding( vec2 uv ){


  float amount = 0.;
  vec3 others = vec3( 0. );

  if( uv.x > iSize ){
    others += texture2D( t_pos , uv - vec2( iSize , 0. ) ).xyz;
    amount += 1.;
  }
   
  if( uv.x < 1.- iSize ){
    others += texture2D( t_pos , uv + vec2( iSize , 0. ) ).xyz;
    amount += 1.;
  }

  if( uv.y > iSize ){
    others += texture2D( t_pos , uv - vec2( 0. , iSize ) ).xyz;
    amount += 1.;
  }


  if( uv.y < 1. - iSize ){
    others += texture2D( t_pos , uv + vec2( 0. , iSize ) ).xyz;
    amount += 1.;
  }

  others /= amount;

  return others;


}

void main(){


 
  vec2 uv = gl_FragCoord.xy / resolution;
  vec4 oPos = texture2D( t_oPos , uv );
  vec4 pos  = texture2D( t_pos  , uv );
  vec4 og   = texture2D( t_og   , uv );
  vec3 vel  = pos.xyz - oPos.xyz;
  vec3 p    = pos.xyz;

  vec2 vUv = uv;

  float life = pos.w;
  
  vec3 f = vec3( 0. , 0. , 0. );
 
  vec3 dif = pos.xyz - og.xyz;

  float xPow = abs((uv.x - .5 )); 
  float yPow = abs((uv.y - .5 )); 
  // moving back to og pos.
  f -= dif * .01 ;//* pow(( xPow + yPow ),3.);

  vec3 repel = pos.xyz - vec3( 1. , 0. , 0. );

  // for each repeler in the repeler array, 
  // repel
  for( int i = 0; i < size; i++ ){

    vec3  rP = repelers[ i ];
    vec3  rD = pos.xyz - rP;
    float rL = max( .01 , length( rD ) );
    vec3  rN = normalize( rD );

    float p = power[i].x/256.;
    //float p = 1.;
    if( rL < .05 ){

      f += repulsionPower * 1. * p * rN / pow( rL , 5. );

    }


  }


  float sl = springLength;
  float power = 2.;

  if( vUv.x > iSize ){

    vec3 p1 = texture2D( t_pos , vec2( vUv.x - iSize , vUv.y )).xyz;
    vec3 nP = springForce(  p , p1 , sl );
    if( length( nP ) > .0001 ){
      f += springMultiplier *  normalize( nP ) * pow( length( nP ) , power );
    }

  // If we are all the way to the Left, sample the next cube.
  }/*else{

    vec3 p1 = texture2D( t_posLeft , vec2( 1. - iSize , vUv.y )).xyz;
    vec3 nP = springForce(  p , p1 , sl );
    if( length( nP ) > .0001 ){
      f += springMultiplier *  normalize( nP ) * pow( length( nP ) , power );
    }

  }*/
  
  if( vUv.x < 1. - iSize ){

    vec3 p1 = texture2D( t_pos , vec2( vUv.x + iSize , vUv.y )).xyz;
    vec3 nP = springForce(  p , p1 , sl );
    if( length( nP ) > .0001 ){
      f += springMultiplier *  normalize( nP ) * pow( length( nP ) , power );
    }

  // If we are all the way to the right, sample the next cube.
  }/*else{

    vec3 p1 = texture2D( t_posRight , vec2( iSize , vUv.y )).xyz;
    vec3 nP = springForce(  p , p1 , sl );
    if( length( nP ) > .0001 ){
      f += springMultiplier *  normalize( nP ) * pow( length( nP ) , power );
    }

  }*/

  if( vUv.y > iSize ){

    vec3 p1 = texture2D( t_pos , vec2( vUv.x , vUv.y - iSize)).xyz;
    vec3 nP = springForce(  p , p1 , sl );
    if( length( nP ) > .0001 ){
      f += springMultiplier *  normalize( nP ) * pow( length( nP ) , power );
    }

  // If we are all the way to the bottom, sample the down cube.
  }/*else{

    vec3 p1 = texture2D( t_posBottom , vec2( vUv.x , 1. - iSize )).xyz;
    vec3 nP = springForce(  p , p1 , sl );
    if( length( nP ) > .0001 ){
      f += springMultiplier *  normalize( nP ) * pow( length( nP ) , power );
    }

  }*/


  if( vUv.y < 1. - iSize ){

    vec3 p1 = texture2D( t_pos , vec2( vUv.x , vUv.y + iSize)).xyz;
    vec3 nP = springForce(  p , p1 , sl );
    if( length( nP ) > .0001 ){
      f += springMultiplier *  normalize( nP ) * pow( length( nP ) , power );
    }

 
  }/*else{

    vec3 p1 = texture2D( t_posTop , vec2( vUv.x , iSize )).xyz;
    vec3 nP = springForce(  p , p1 , sl );
    if( length( nP ) > .0001 ){
      f += springMultiplier *  normalize( nP ) * pow( length( nP ) , power );
    }

  }*/

  /*if( vUv.y < 1. - iSize && vUv.x < 1. - iSize ){

    vec3 p1 = texture2D( t_pos , vec2( vUv.x + iSize , vUv.y + iSize)).xyz;
    vec3 nP = springForce(  p , p1 , pow( 2. * sl*sl , .5 )  );
    if( length( nP ) > .0001 ){
      f += springMultiplier *  normalize( nP ) * pow( length( nP ) , power );
    }
  }

  if( vUv.y > iSize && vUv.x < 1. - iSize ){

    vec3 p1 = texture2D( t_pos , vec2( vUv.x + iSize , vUv.y - iSize)).xyz;
    vec3 nP = springForce(  p , p1 , pow( 2. * sl*sl , .5 )  );
    if( length( nP ) > .0001 ){
      f += springMultiplier *  normalize( nP ) * pow( length( nP ) , power );
    }


  }

  if( vUv.y > iSize && vUv.x > iSize ){

    vec3 p1 = texture2D( t_pos , vec2( vUv.x - iSize , vUv.y - iSize)).xyz;
    vec3 nP = springForce(  p , p1 , pow( 2. * sl*sl , .5 )  );
    if( length( nP ) > .0001 ){
      f += springMultiplier *  normalize( nP ) * pow( length( nP ) , power );
    }

  }
  
  if( vUv.y < 1. - iSize && vUv.x > iSize ){

    vec3 p1 = texture2D( t_pos , vec2( vUv.x - iSize , vUv.y + iSize)).xyz;

    vec3 nP = springForce(  p , p1 , pow( 2. * sl*sl , .5 )  );
    if( length( nP ) > .0001 ){
      f += springMultiplier *  normalize( nP ) * pow( length( nP ) , power );
    }

  }*/
  

  vel += f*min( .1 , dT);
  vel *= dampening;

  if( length( vel ) > .001 ){

    vel = normalize( vel ) * .001;

  }
  p += vel * 1.;//speed;*/

  vec3 o = getSurrounding( uv );
  vec3 oDif = o - p;
  p += oDif * .01;

  


  /*if( vUv.y < iSize || vUv.y > 1. - iSize || vUv.x < iSize || vUv.x > 1. - iSize  ){
    p = pos.xyz;
  }*/

  //gl_FragColor = vec4( og.xyz + sin( timer ) * 1.* vec3( vUv.x , vUv.y , 0. ), 1.  );
  gl_FragColor = vec4( p , life );

}
