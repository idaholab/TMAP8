!template load file=sqa/app_rtm.md.template app=TMAP8 category=tmap8

!template! item key=system-scope 
!include tmap8_srs.md start=system-scope-begin end=system-scope-finish 
!template-end!

!template! item key=system-purpose 
!include tmap8_srs.md start=system-purpose-begin end=system-purpose-finish
!template-end!

!template! item key=log-revisions
Currently, no errors in issue references related to the changelog have been discovered. 
!template-end!
