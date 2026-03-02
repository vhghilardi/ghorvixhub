{*******************************************************************************
  Ghorvix Hub API Client - Design-time Registration
  Registro do componente na paleta do Delphi
*******************************************************************************}
unit GhorvixHubClientReg;

interface

procedure Register;

implementation

uses
  System.Classes, GhorvixHubClient;

procedure Register;
begin
  RegisterComponents('Ghorvix', [TGhorvixHubClient]);
end;

end.
