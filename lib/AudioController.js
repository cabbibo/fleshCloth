
function AudioController( listener ){

 /* try {
    window.AudioContext = window.AudioContext;//||window.webkitAudioContext;
  }catch(e) {
    alert( 'WEB AUDIO API NOT SUPPORTED' );
  }*/
 
  this.ctx      = new AudioContext();

  this.mute     = this.ctx.createGain();
  this.gain     = this.ctx.createGain();
  this.analyzer = this.ctx.createAnalyser();

  this.analyzer.frequencyBinCount = 1024;
  this.analyzer.array = new Uint8Array( this.analyzer.frequencyBinCount );


  this.audioTexture  = new AudioTexture( this );
  
  this.texture = this.audioTexture.texture;

  this.gain.connect( this.analyzer );
  this.analyzer.connect( this.mute );
  this.mute.connect( this.ctx.destination );

  this.updateArray = [];

  this.notes = [];

}


AudioController.prototype.update = function(){

  this.analyzer.getByteFrequencyData( this.analyzer.array );

  this.audioTexture.update();

    var l = this.ctx.listener;

    var f = new THREE.Vector3( 0 , 0 , -1 );
    f.applyQuaternion( camera.quaternion );

    var u = new THREE.Vector3( 0 , 1 , 0);
    u.applyQuaternion( camera.quaternion );


    this.ctx.listener.setOrientation( f.x, f.y , f.z, u.x , u.y , u.z );

  
  for( var i = 0; i < this.notes.length; i++ ){

    this.notes[i].update();

  }

  for( var i = 0; i < this.updateArray.length; i++ ){

    this.updateArray[i]();

  }



}

AudioController.prototype.addToUpdateArray = function( callback ){

  this.updateArray.push( callback );

}

AudioController.prototype.removeFromUpdateArray = function( callback ){

  for( var i = 0; i< this.updateArray.length; i++ ){

    if( this.updateArray[i] === callback ){

      this.updateArray.splice( i , 1 );
      console.log( 'SPLICED' );

    }

  }

}




