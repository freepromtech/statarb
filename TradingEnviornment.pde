TradingEnviornment TE[];

class TradingEnviornment
  {
    AlertSystem            TradeAlert;
    AlertSystem            LearnAlert;
    
    TimeSeries             P1;
    TimeSeries             P2;
    
    int                    Samp = 10;
    double                 Upper;
    double                 Lower;
    double                 Ratio;
    
    boolean Open = false;
    boolean Side = true;
    
    int     Learn = 480;
    String  Pair1;
    String  Pair2;
    
    double Allocation = 1600;
    
    Table table;
    
    boolean Winningest;
    
    public TradingEnviornment( String _P1_, String _P2_, double Alloc )
      { 
        Allocation = Alloc;
        try
          {
             table = loadTable( "data/pairs" + _P1_ + "_" + _P2_ + ".csv" );
             String val = table.getRow( 1 ).getString( 0 );
             
            
             if( Integer.parseInt( val ) == 0 )
               {
                 Side = false;
                 Open = true;
               }
             
             if( Integer.parseInt( val ) == 1 )
               {
                 Side = true;
                 Open = true;
               }
               
             System.out.println( ( new Date().toString() ) + "› Loaded Position " + _P1_ + " " + _P2_ );
          }
        catch( Exception e )
          {
            table = new Table();
            
            table.addColumn( "Position" );
            table.addColumn( "Pair 1" );
            table.addColumn( "Pair 2" );
            
            TableRow newRow = table.addRow();
            newRow.setInt( "Position", -1 );
            newRow.setString( "Pair 1", _P1_ );
            newRow.setString( "Pair 2", _P2_ );
            
            saveTable( table, "data/pairs" + _P1_ + "_" + _P2_ + ".csv" );
            
            System.out.println( ( new Date().toString() ) + "› Created Postion Status File " + _P1_ + " " + _P2_ );
          }
          
        TradeAlert    = new AlertSystem();
        LearnAlert    = new AlertSystem();
                
        Pair1 = _P1_;
        Pair2 = _P2_;
        
        P1 = new TimeSeries();
        P1.OandaDownloadHistory( Pair1, 5000, "H1" );
        
        P2 = new TimeSeries();
        P2.OandaDownloadHistory( Pair2, 5000, "H1" );
        
        Backtester B = new Backtester();
        
        Ratio = 0;
        double Max = -1;
        double _Upper_ = 0;
        double _Lower_ = 0;
        
        
        ApplyMachineLearning();
      }
      
    void ApplyMachineLearning()
      {
        P1 = new TimeSeries();
        P1.OandaDownloadHistory( Pair1, 250*20, "H1" );
        
        P2 = new TimeSeries();
        P2.OandaDownloadHistory( Pair2, 250*20, "H1" );
        
        Backtester B = new Backtester();
        
        double Max = -1;
        double _Upper_ = 0;
        double _Lower_ = 0;
        
        float V = millis();
        /*
        for( int _U_ = 4; _U_ < 25; _U_++ )
          {
            for( int _L_ = 1; _L_ < 25; _L_++ )
              {
                if( _U_ > _L_ )
                  {
                    double __U__ = ( ( double ) _U_ )/1000;
                    double __L__ = ( ( double ) _L_ )/1000;
                    double Value = B.Run( P1, P2, __U__, __L__, 480*4 );
                    
                    if( Value >= Max )
                      {
                        Max      = Value;
                        _Upper_  = __U__;
                        _Lower_  = __L__;
                      }
                  }
              }
          }*/
        
        if( true || Upper != _Upper_ || Lower != _Lower_ )
          {
            Upper  = 0.006;//_Upper_;
            Lower  = 0.002;//_Lower_;
            
            Winningest = B.Run( P1, P2, Upper, Lower, 120*4 ) > 0;
            
            System.out.println( ( new Date() ).toString() + "› " + Pair1 + " " + Pair2 + " One Month Return: " +  B.Run( P1, P2, Upper, Lower, 120*4 ) );
            
            if( Winningest )
              {
                System.out.println( ( new Date() ).toString() + "› " + Pair1 + " " + Pair2 +  " Active" );
              }
            
            System.out.println( ( new Date() ).toString() + "› " + Pair1 + " " + Pair2 + " E "+ Max + " RECONFIG PARAM VECTOR (" + Upper + "," + Lower + ") Return:" + B.Run( P1, P2, Upper, Lower, 480*4 ) );
          }
          
      }
      
    void Trade( boolean Real, boolean Flip )
      {
        TimeSeries ADF = new TimeSeries();
        
        double Correlation = 0;
        
        for( int x = 1; x < 121; x++ )
          {
            Correlation += ( P1.GetBid( x )/P2.GetBid( x ) )/120;
          }
          
        if( Ratio != P1.GetBid( 1 )/P2.GetBid( 1 ) )
          {
            Ratio = P1.GetBid( 1 )/P2.GetBid( 1 );
            System.out.println( ( new Date() ).toString() + "› " + ( P1.GetAsk( 0 ) - P1.GetBid( 0 ) )/P1.GetAsk( 0 ) + " " + ( ( P2.GetAsk( 0 ) - P2.GetBid( 0 ) ) )/P2.GetAsk( 0 ) + " " + Pair1 + " " + Pair2 + " DIFFERENTIAL " + ( Ratio/Correlation - 1 ) );
          }
    
        double V = P1.CorrelationCofficient( P2, 0, 96 );
        
        if( !Open )
          {
            double A1 = 1/( ( ( P1.StandardDeviation( 1, 24*20*4 ) ) )/P1.GetBid( 1 ) );
            double A2 = 1/( ( ( P2.StandardDeviation( 1, 24*20*4 ) ) )/P2.GetBid( 1 ) );
            double Sum = ( A1 + A2 );
            
            A1 /= Sum;
            A2 /= Sum;
            
            if( P1.GetBid( 1 )/P2.GetBid( 1 ) > Correlation*( 1+Upper ) && ( P1.GetAsk( 0 ) - P1.GetBid( 0 ) )/P1.GetAsk( 0 ) < 0.001 && ( ( P2.GetAsk( 0 ) - P2.GetBid( 0 ) ) )/P2.GetAsk( 0 ) < 0.001 )
              {
                Open = true;
                Side = true;
                System.out.println( ( new Date() ).toString() + "› " + Pair1 + ": " + -floor( ( float ) ( Allocation*A1 ) ) + " " + Pair2 + ": " + floor( ( float ) ( Allocation*A2 ) ) );
                
                try
                  {
                    table = new Table();
                    
                    table.addColumn( "Position" );
                    table.addColumn( "Pair 1" );
                    table.addColumn( "Pair 2" );
                    
                    TableRow newRow = table.addRow();
                    newRow.setInt( "Position", 1 );
                    newRow.setString( "Pair 1", Pair1 );
                    newRow.setString( "Pair 2", Pair2 );
                    
                    saveTable( table, "data/pairs" + Pair1 + "_" + Pair2 + ".csv" );
                    
                    System.out.println( ( new Date().toString() ) + "› Edited Postion Status File " + Pair1 + " " + Pair2 );
                  }
                catch( Exception e )
                  {
                    e.printStackTrace();
                  }
                  
                if( Real )
                  {
                    if( Flip )
                      {
                        FXTrade.send_order( Pair1, "sell", "" + floor( ( float ) ( ( 1/P1.GetBid( 1 ) ) * floor( ( float ) ( Allocation*A1 ) ) ) ) );
                        FXTrade.send_order( Pair2, "buy", "" + floor( ( float ) ( ( 1/P2.GetBid( 1 ) ) * floor( ( float ) ( Allocation*A2 ) ) ) ) );
                      }
                    else
                      {  
                        FXTrade.send_order( Pair1, "sell", "" + floor( ( float ) ( Allocation*A1 ) ) );
                        FXTrade.send_order( Pair2, "buy", "" + floor( ( float ) ( Allocation*A2 ) ) );
                      }
                  }
              }
              
            if( P1.GetBid( 1 )/P2.GetBid( 1 ) < Correlation*( 1-Upper ) && ( P1.GetAsk( 0 ) - P1.GetBid( 0 ) )/P1.GetAsk( 0 ) < 0.001 && ( ( P2.GetAsk( 0 ) - P2.GetBid( 0 ) ) )/P2.GetAsk( 0 ) < 0.001 )
              {
                Open = true;
                Side = false;
                System.out.println( ( new Date() ).toString() + "› " + Pair1 + ": " + floor( ( float ) ( Allocation*A1 ) ) + " " + Pair2 + ": " + -floor( ( float ) ( Allocation*A2 ) ) );
                
                try
                  {
                    table = new Table();
                    
                    table.addColumn( "Position" );
                    table.addColumn( "Pair 1" );
                    table.addColumn( "Pair 2" );
                    
                    TableRow newRow = table.addRow();
                    newRow.setInt( "Position", 0 );
                    newRow.setString( "Pair 1", Pair1 );
                    newRow.setString( "Pair 2", Pair2 );
                    
                    saveTable( table, "data/pairs" + Pair1 + "_" + Pair2 + ".csv" );
                    
                    System.out.println( ( new Date().toString() ) + "› Edited Postion Status File " + Pair1 + " " + Pair2 );
                  }
                catch( Exception e )
                  {
                    e.printStackTrace();
                  }
                  
                if( Real )
                  {
                    if( true )
                      {
                        if( Flip )
                          {
                            FXTrade.send_order( Pair1, "buy", "" + floor( ( float ) ( ( 1/P1.GetBid( 1 ) ) * floor( ( float ) ( Allocation*A1 ) ) ) ) );
                            FXTrade.send_order( Pair2, "sell", "" + floor( ( float ) ( ( 1/P2.GetBid( 1 ) ) * floor( ( float ) ( Allocation*A2 ) ) ) ) );
                          }
                        else
                          {  
                            FXTrade.send_order( Pair1, "buy", "" + floor( ( float ) ( Allocation*A1 ) ) );
                            FXTrade.send_order( Pair2, "sell", "" + floor( ( float ) ( Allocation*A2 ) ) );
                          }
                      }
                  }
              }
          }
        else
          {
            if( Side == true && P1.GetBid( 1 )/P2.GetBid( 1 ) < Correlation*( 1+Lower ) )
              {
                try
                  {
                    table = new Table();
                    
                    table.addColumn( "Position" );
                    table.addColumn( "Pair 1" );
                    table.addColumn( "Pair 2" );
                    
                    TableRow newRow = table.addRow();
                    newRow.setInt( "Position", -1 );
                    newRow.setString( "Pair 1", Pair1 );
                    newRow.setString( "Pair 2", Pair2 );
                    
                    saveTable( table, "data/pairs" + Pair1 + "_" + Pair2 + ".csv" );
                    
                    System.out.println( ( new Date().toString() ) + "› Edited Postion Status File " + Pair1 + " " + Pair2 );
                  }
                catch( Exception e )
                  {
                    e.printStackTrace();
                  }
                
                delay( 1000 );
                
                Open = false;
                System.out.println( ( new Date() ).toString() + "› " + Pair1 + " " + Pair2 + " CLOSE TRADE" );
                FXTrade.close_order( Pair1 );
                FXTrade.close_order( Pair2 );
              }
              
            if( Side == false && P1.GetBid( 1 )/P2.GetBid( 1 ) > Correlation*( 1-Lower ) )
              {
                
                try
                  {
                    table = new Table();
                    
                    table.addColumn( "Position" );
                    table.addColumn( "Pair 1" );
                    table.addColumn( "Pair 2" );
                    
                    TableRow newRow = table.addRow();
                    newRow.setInt( "Position", -1 );
                    newRow.setString( "Pair 1", Pair1 );
                    newRow.setString( "Pair 2", Pair2 );
                    
                    saveTable( table, "data/pairs" + Pair1 + "_" + Pair2 + ".csv" );
                    
                    System.out.println( ( new Date().toString() ) + "› Edited Postion Status File " + Pair1 + " " + Pair2 );
                  }
                catch( Exception e )
                  {
                    e.printStackTrace();
                  }
                
                delay( 1000 );
                
                Open = false;
                System.out.println( ( new Date() ).toString() + "› " + Pair1 + " " + Pair2 + " CLOSE TRADE" );
                FXTrade.close_order( Pair1 );
                FXTrade.close_order( Pair2 );
              }
          }
      }
  }
