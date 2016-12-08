GraphicsInterface GRAPH_INTER;

class GraphicsInterface
  {
    ControlP5 cp5;
    Textarea myTextarea;
    Println console;
    
    public GraphicsInterface( PApplet PA )
      {
        cp5 = new ControlP5( PA );
        myTextarea = cp5.addTextarea( "txt" )
                      .setPosition( 0, 0 )
                      .setSize( width, height )
                      .setFont( createFont( "", 10 ) )
                      .setLineHeight( 14 )
                      .setColor( color( 255 ) )
                      .setColorBackground( color( 0 ) )
                      .setColorForeground( color( 255 ) );
        ;
        
        console = cp5.addConsole( myTextarea );
      }
      
    void Draw()
      {
        myTextarea.setSize( ( int ) ( width ), height/2 );
      }
  }
