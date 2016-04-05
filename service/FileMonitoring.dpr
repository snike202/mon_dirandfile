program FileMonitoring;

uses
  SvcMgr,
  Forms,
  Sysutils,
  Windows,
  WinSVC,
  //antivirus,
  PrevInst,
  main in 'main.pas' {FileMon: TService},
  aboutform in 'aboutform.pas' {fabout};

{$R *.RES}

function Installing: Boolean;
begin
 Result:=FindCmdLineSwitch('install',['-',' ','/'], True) or
  FindCmdLineSwitch('uninstall',['-',' ','/'], True);
end;

function StartService: Boolean;
var
 mgr, svc: integer;
 username, servicestartname: string;
 config: pointer;
 size: dword;
begin
 Result:=False;
 mgr:=OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
 if mgr <> 0 then begin
  svc:=OpenService(mgr, pchar('FileMon'), SERVICE_ALL_ACCESS);
  Result:=svc <> 0;
  if Result then begin
   QueryServiceConfig(svc, nil, 0, size);
   config:=AllocMem(size);
   try
    QueryServiceConfig(svc, config, size, size);
    servicestartname:=PQueryServiceConfig(config)^.lpServiceStartName;
    if CompareText(servicestartname, 'localsystem') = 0 then servicestartname:='system';
   finally
    Dispose(config);
   end;
   CloseServiceHandle(svc);
  end;
  CloseServiceHandle(mgr);
 end;
 if Result then begin
  size:=256;
  SetLength(username, size);
  GetUserName(pchar(username), size);
  SetLength(username, strlen(pchar(username)));
  Result:=CompareText(username, servicestartname) = 0;
 end;
end;

begin
 if mt('FileMonitoring') then halt;
 if Installing or StartService then begin
  SvcMgr.Application.Initialize;
  Application.ShowMainForm:=false;
  SvcMgr.Application.CreateForm(Tfabout, fabout);
  SvcMgr.Application.CreateForm(tFileMon, FileMon);
  SvcMgr.Application.run;
 end else begin
  Forms.Application.Initialize;
  Forms.Application.CreateForm(tfabout, fabout);
  Forms.Application.Run;
 end;
end.
