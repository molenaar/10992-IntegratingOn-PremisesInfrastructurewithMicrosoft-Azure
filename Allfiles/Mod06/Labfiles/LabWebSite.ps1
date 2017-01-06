Configuration LabWebSite
{
    Import-DscResource -ModuleName (@{ModuleName='xWebAdministration';ModuleVersion='1.12.0.0'})
        
    Node localhost
    {
 	# Install the Web Server role
        WindowsFeature IIS
        {
            Ensure	 		= "Present"
            Name	 		= "Web-Server"
        }
    	# Install the Web Management role service
        WindowsFeature WebManagementService
        {
            Ensure	 		= "Present"
            Name	 		= "Web-Mgmt-Service"
        }
        # Ensure that the default website is started
    	# Install the ASP.NET 4.5 role service
        WindowsFeature DotNet45
        {
            Ensure	 		= "Present"
            Name	 		= "Web-Asp-Net45"
        }
        xWebsite DefaultSite   
        {  
            Ensure	 		= "Present"  
            Name	 		= "Default Web Site"  
            State	 		= "Started"  
            PhysicalPath 		= "C:\inetpub\wwwroot"  
            DependsOn	 		= "[WindowsFeature]IIS"  
        }  
    }
}