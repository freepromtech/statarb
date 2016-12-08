class Backtester
  {
    public Backtester()
      {
        
      }
      
    double CalculateVolatility( TimeSeries P1, TimeSeries P2, int Length )
      {
        TimeSeries ADF = new TimeSeries();
        double ACCBAL = 0;
        
        for( int i = Length+1; i >= 1; i-- )
          {
            double A1 = 1/( ( ( P1.StandardDeviation( i, 24*20*4 ) ) )/P1.GetBid( i ) );
            double A2 = 1/( ( ( P2.StandardDeviation( i, 24*20*4 ) ) )/P2.GetBid( i ) );
            double Sum = ( A1 + A2 );
            
            A1 /= Sum;
            A2 /= Sum;
            ACCBAL += ( ( ( P1.GetBid( i )-P1.GetBid( i+1 ) )/ P1.GetBid( i+1 ) )*A1 )-( ( ( P2.GetBid( i )-P2.GetBid( i+1 ) )/ P2.GetBid( i+1 ) )*A2 );
            
            AssetDataFrame ADF2 = new AssetDataFrame();
            ADF2.SetValues( "-1", "LMAO", ACCBAL, ACCBAL );
            
            ADF.Add( ADF2 );
          }
          
        return ADF.StandardDeviation( 0, Length );
      }
      
    double Run( TimeSeries P1, TimeSeries P2, double Upper, double Lower, int Length )
      {
        Upper= 0.006;
        Lower = 0.002;
        boolean Open = false;
        boolean Side = true;
        
        double AccountBalance = 0;
        double Correlation = 0;
        TimeSeries ADF = new TimeSeries();
        
        for( int i = Length+1; i >= 1; i-- )
          {
            for( int x = 1; x < 121; x++ )
              {
                Correlation += ( P1.GetBid( i+x )/P2.GetBid( i+x ) )/120;
              }
            
            double V = P1.CorrelationCofficient( P2, i, 96 );
            
            if( !Open )
              {
                if( P1.GetBid( i )/P2.GetBid( i ) > Correlation*( 1+Upper ) )
                  {
                    Open = true;
                    Side = true;
                    AccountBalance -= 0.0005;
                  }
                if( P1.GetBid( i )/P2.GetBid( i ) < Correlation*( 1-Upper ) )
                  {
                    Open = true;
                    Side = false;
                    AccountBalance -= 0.0005;
                  }
              }
            else
              {
                double A1 = 1/( ( ( P1.StandardDeviation( i, 24*20*4 ) ) )/P1.GetBid( i ) );
                double A2 = 1/( ( ( P2.StandardDeviation( i, 24*20*4 ) ) )/P2.GetBid( i ) );
                double Sum = ( A1 + A2 );
                
                A1 /= Sum;
                A2 /= Sum;
                
                if( Side )
                  {
                    AccountBalance -= ( P1.GetBid( i-1 ) - P1.GetBid( i ) )/P1.GetBid( i )  *A1;
                    AccountBalance += ( P2.GetBid( i-1 ) - P2.GetBid( i ) )/P2.GetBid( i )  *A2;
                  }
                else
                  {
                    AccountBalance += ( P1.GetBid( i-1 ) - P1.GetBid( i+1 ) )/P1.GetBid( i+1 )  *A1;
                    AccountBalance -= ( P2.GetBid( i-1 ) - P2.GetBid( i ) )/P2.GetBid( i+1 )  *A2;
                  }
                
                if( Side == true && P1.GetBid( i )/P2.GetBid( i ) < Correlation*( 1+Lower ) )
                  {
                    Open = false;
                  }
                  
                if( Side == false && P1.GetBid( i )/P2.GetBid( i ) > Correlation*( 1-Lower ) )
                  {
                    Open = false;
                  }
              }
          }
          
        return AccountBalance;
      }
  }
