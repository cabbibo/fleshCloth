function Wrapper( audioController ){

  this.audioController = audioController;
  this.ctx = audioController.ctx;    
  var blockSize = 2048

  this.patch = new testLib({
    blockSize: blockSize,
    //printHook: hvPrintHook,
    //sendHook: hvSendHook
  });


  this.node = this.ctx.createScriptProcessor(
    blockSize,
    this.patch.getNumInputChannels(),
    // Note: make sure there is at least one output channel specified so that
    // we can process patches that have no i/o objects (i.e. control only)
    Math.max(this.patch.getNumOutputChannels(), 1)
  );

  this.node.onaudioprocess = function(e) { this.patch.process(e); }.bind( this );


}

Wrapper.prototype.start = function(){

  this.node.connect( this.audioController.gain );


}

Wrapper.prototype.stop = function(){

  this.node.disconnect( this.audioController.gain );

}

Wrapper.prototype.setValue = function( name , value ){
  this.patch.sendFloatToReceiver( name , value );
}



