-- Import Hardware info from KES Server, sum up the memory and identify WIndows -- 
SELECT        TOP (100) PERCENT wstrDisplayName, nHost, wstrName AS DeviceName, SUM(nCapacity) AS Capacity, strMAC AS MAC, IP_Address, 
                         CASE WHEN nProcType = '2' THEN 'AMD64' WHEN nProcType = '1' THEN 'X86' ELSE 'NONE' END AS CPU_Architecture, CASE WHEN nVersionMajor = '6' AND 
                         nVersionMinor = '1' THEN 'Winodws 7' WHEN nVersionMajor = '6' AND nVersionMinor = '2' THEN 'Winodws Server 2012' 
						 WHEN nVersionMajor = '10' AND 
                         nVersionMinor = '0' THEN 'Winodws 10'
						 WHEN nVersionMajor = '5' AND 
                         nVersionMinor = '1' THEN 'Winodws XP' 
						 						 WHEN nVersionMajor = '6' AND 
                         nVersionMinor = '3' THEN 'Winodws Server 2012 R2' ELSE 'NONE' END AS Windows_version
FROM            (SELECT        dbo.v_akpub_hwinv.nHost, dbo.v_akpub_host.wstrDisplayName, dbo.v_akpub_host.wstrDnsDomain, dbo.v_akpub_host.nVersionMajor, 
                                                    dbo.v_akpub_host.nVersionMinor, dbo.v_akpub_host.nIp, dbo.v_akpub_host.nConnectionIp, dbo.v_akpub_host.nProcType, dbo.v_akpub_host.nSpMajor, 
                                                    dbo.v_akpub_host.nSpMinor, dbo.v_akpub_hwinv.wstrName, dbo.v_akpub_hwinv.nCapacity, dbo.v_akpub_hwinv.nSpeed, dbo.v_hosts.strAddress, 
                                                    CASE WHEN dbo.v_hosts.strAddress LIKE 'http://%' THEN CHARINDEX(':15000', dbo.v_hosts.strAddress) 
                                                    - 8 ELSE dbo.v_hosts.strAddress END AS straddressv2, SUBSTRING(dbo.v_hosts.strAddress, 8, 
                                                    CASE WHEN dbo.v_hosts.strAddress LIKE 'http://%' THEN CHARINDEX(':15000', dbo.v_hosts.strAddress) - 8 ELSE dbo.v_hosts.strAddress END) 
                                                    AS IP_Address, dbo.v_akpub_hwinv.strMAC
                          FROM            dbo.v_akpub_host INNER JOIN
                                                    dbo.v_akpub_hwinv ON dbo.v_akpub_host.nId = dbo.v_akpub_hwinv.nHost INNER JOIN
                                                    dbo.v_hosts ON dbo.v_akpub_hwinv.nHost = dbo.v_hosts.nId
                          WHERE         (dbo.v_akpub_hwinv.strMAC like '%:%') OR
                                                     (dbo.v_akpub_hwinv.nCapacity < 20000) OR(dbo.v_akpub_hwinv.wstrName LIKE '%CPU%') )AS v_public_hardware
GROUP BY nHost, wstrDisplayName, wstrName, nVersionMinor, nVersionMajor, strMAC, nProcType, IP_Address
ORDER BY nHost