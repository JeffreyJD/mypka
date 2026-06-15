
$word = New-Object -ComObject Word.Application
$word.Visible = $false
$doc  = $word.Documents.Add()
$sel  = $word.Selection

# Margins
$doc.PageSetup.TopMargin    = $word.InchesToPoints(0.75)
$doc.PageSetup.BottomMargin = $word.InchesToPoints(0.75)
$doc.PageSetup.LeftMargin   = $word.InchesToPoints(0.85)
$doc.PageSetup.RightMargin  = $word.InchesToPoints(0.85)

# Colors  R + G*256 + B*65536
$Navy   = 31 + 56*256 + 100*65536
$DkGray = 64 + 64*256 + 64*65536
$MdGray = 128 + 128*256 + 128*65536
$Black  = 0
$White  = 16777215

function wPt { param($inch); $word.InchesToPoints($inch) }

function ResetFont {
    $sel.Font.Name      = "Calibri"
    $sel.Font.Size      = 10
    $sel.Font.Bold      = $false
    $sel.Font.Italic    = $false
    $sel.Font.Color     = $Black
    $sel.Font.AllCaps   = $false
    $sel.Font.Underline = 0
    $sel.ParagraphFormat.LeftIndent      = 0
    $sel.ParagraphFormat.FirstLineIndent = 0
}

function Para {
    param([int]$before=0,[int]$after=4,[int]$align=0)
    $sel.ParagraphFormat.SpaceBefore     = $before
    $sel.ParagraphFormat.SpaceAfter      = $after
    $sel.ParagraphFormat.Alignment       = $align
    $sel.ParagraphFormat.LineSpacingRule = 0
    $sel.ParagraphFormat.KeepWithNext    = $false
}

# ── NAME ──────────────────────────────────────────────────────────────────────
Para 0 2 0
$sel.Font.Name  = "Calibri"
$sel.Font.Size  = 26
$sel.Font.Bold  = $true
$sel.Font.Color = $Navy
$sel.TypeText("Jeffrey J. Davis")
$sel.TypeParagraph()

Para 0 10 0
$sel.Font.Size  = 9
$sel.Font.Bold  = $false
$sel.Font.Color = $MdGray
$sel.TypeText("Erie, Pennsylvania   |   (814) 920-3947   |   jeff@davisglobe.com   |   linkedin.com/in/jeffrey-davis-690b7150")
$sel.TypeParagraph()

# Thin rule
Para 0 6 0
$sel.Font.Size  = 1
$sel.Font.Color = $White
$sel.ParagraphFormat.Borders.Item(3).LineStyle = 1
$sel.ParagraphFormat.Borders.Item(3).LineWidth = 8
$sel.ParagraphFormat.Borders.Item(3).Color     = $Navy
$sel.TypeText(" ")
$sel.TypeParagraph()
ResetFont

# ── SECTION HEADER ────────────────────────────────────────────────────────────
function SectionHead { param([string]$title)
    ResetFont
    Para 10 2 0
    $sel.ParagraphFormat.KeepWithNext = $true
    $sel.Font.Size    = 11
    $sel.Font.Bold    = $true
    $sel.Font.Color   = $Navy
    $sel.Font.AllCaps = $true
    $sel.TypeText($title)
    $sel.TypeParagraph()
    $sel.Font.AllCaps = $false
    # rule under
    Para 0 6 0
    $sel.Font.Size  = 1
    $sel.Font.Color = $White
    $sel.ParagraphFormat.Borders.Item(3).LineStyle = 1
    $sel.ParagraphFormat.Borders.Item(3).LineWidth = 4
    $sel.ParagraphFormat.Borders.Item(3).Color     = $Navy
    $sel.TypeText(" ")
    $sel.TypeParagraph()
    ResetFont
}

# ── EXECUTIVE PROFILE ─────────────────────────────────────────────────────────
SectionHead "Executive Profile"

Para 0 5 3
$sel.Font.Color = $Black
$sel.TypeText("Thirty years implementing Oracle ERP at the world's most demanding enterprises. Director-level practice leader with full P&L ownership across ERP, SCM, HCM, EPM, and Managed Services spanning six countries - overseeing `$25-`$30M in annual practice revenue. Pioneer of AI-First Oracle delivery - building the methodology that defines how implementations work in the AI era.")
$sel.TypeParagraph()

Para 0 5 3
$sel.TypeText("Currently leading Perficient's Oracle Practice transformation using a three-platform architecture: Celonis for process intelligence, Rapid4Cloud for configuration automation, and Claude as the AI layer across delivery. Built Meridian - a custom LLM application on the Anthropic API - for program forecasting and delivery risk prediction. This is not someone who talks about AI in consulting. This is someone who builds it.")
$sel.TypeParagraph()

Para 0 5 3
$sel.TypeText("Prior to Perficient, spent 14 years at General Electric as Global ERP Transformation Leader - extending GE Transportation's Oracle instance to Brazil, China, Europe, and Kazakhstan while driving a 50% reduction in total cost of ownership.")
$sel.TypeParagraph()

# ── CORE COMPETENCIES ────────────────────────────────────────────────────────
SectionHead "Core Competencies"

$comps = @(
    "Practice Leadership   |   Oracle Cloud ERP / SCM / HCM / EPM   |   AI-First Delivery Methodology",
    "P+L Ownership   |   Global Program Management   |   PMO Governance",
    "Business Transformation   |   Process Intelligence (Celonis)   |   Change Management",
    "Oracle EBS R11i / R12 / Cloud   |   Six Sigma DMAIC   |   Executive Stakeholder Management"
)
foreach ($c in $comps) {
    Para 0 2 0
    ResetFont
    # fix P+L back to P&L
    $display = $c -replace 'P\+L','P&L'
    $sel.TypeText($display)
    $sel.TypeParagraph()
}

# ── CAREER HISTORY ────────────────────────────────────────────────────────────
SectionHead "Career History"

function EmployerHead { param([string]$name)
    ResetFont
    Para 8 1 0
    $sel.ParagraphFormat.KeepWithNext = $true
    $sel.Font.Size  = 11
    $sel.Font.Bold  = $true
    $sel.Font.Color = $Navy
    $sel.TypeText($name)
    $sel.TypeParagraph()
    ResetFont
}

function RoleLine { param([string]$title,[string]$dates)
    Para 0 1 0
    $sel.ParagraphFormat.KeepWithNext = $true
    $sel.Font.Size  = 10
    $sel.Font.Bold  = $true
    $sel.Font.Color = $Black
    $sel.TypeText($title)
    $sel.Font.Bold  = $false
    $sel.Font.Color = $MdGray
    $sel.TypeText("   |   " + $dates)
    $sel.TypeParagraph()
    ResetFont
}

function BodyText { param([string]$text,[int]$before=0,[int]$after=4)
    Para $before $after 3
    $sel.Font.Color = $Black
    $sel.TypeText($text)
    $sel.TypeParagraph()
    ResetFont
}

function AchHead { param([string]$title,[string]$detail)
    Para 5 1 0
    $sel.ParagraphFormat.KeepWithNext = $true
    $sel.Font.Size  = 10
    $sel.Font.Bold  = $true
    $sel.Font.Color = $Black
    $sel.TypeText($title + "  ")
    $sel.Font.Bold   = $false
    $sel.Font.Italic = $true
    $sel.Font.Color  = $DkGray
    $sel.TypeText($detail)
    $sel.TypeParagraph()
    ResetFont
}

function BulletLine { param([string]$text)
    Para 0 2 0
    $sel.ParagraphFormat.LeftIndent      = wPt(0.2)
    $sel.ParagraphFormat.FirstLineIndent = wPt(-0.15)
    $sel.Font.Color = $Black
    $sel.TypeText([char]0x2022 + "  " + $text)
    $sel.TypeParagraph()
    $sel.ParagraphFormat.LeftIndent      = 0
    $sel.ParagraphFormat.FirstLineIndent = 0
    ResetFont
}

# PERFICIENT
EmployerHead "Perficient, Inc."
RoleLine "Delivery Unit Leader - Oracle Practice"         "January 2026 - Present"
RoleLine "Engagement Director - Oracle"                   "July 2024 - December 2025"
RoleLine "PMO Director - Oracle ERP National Business Unit" "June 2016 - June 2024"
RoleLine "Delivery Director - Oracle ERP"                 "July 2014 - May 2016"
RoleLine "Senior Project Manager - Oracle ERP"            "December 2012 - June 2014"

BodyText "P&L owner for Perficient's Oracle practice across ERP, SCM, HCM, EPM, and Managed Services in six countries. 13-year progression from Senior Project Manager to Delivery Unit Leader." 3 5

Para 2 2 0
$sel.Font.Bold = $true; $sel.Font.Color = $Black
$sel.TypeText("Selected Achievements:")
$sel.TypeParagraph()
ResetFont

AchHead "AI-First Transformation" "(2025-Present)"
BodyText "Architecting Perficient's AI-First Oracle delivery model - Celonis + Rapid4Cloud + Claude - to reduce implementation cycle time and differentiate Perficient's Oracle practice at the market level. Built Meridian, a custom LLM forecasting application for program delivery risk prediction. Results: 25-40% reduction in implementation timeline; 60% reduction in Level 1 support tickets post go-live." 0 4

AchHead "17-Country Latin America Program" "(2016-2018, `$8M+ Budget)"
BodyText "Program Manager and PMO Leader for a three-year, seventeen-country Oracle EBS business improvement program for a large chemical distributor. Full suite: Financials, Supply Chain, Engineering, and Value Chain Planning. Delivered on time. On budget. Across 17 countries." 0 4

AchHead "Global Acquisition Integration - Apparel" "(2014-2015, `$4M Budget)"
BodyText "Led five-project program to integrate a newly acquired company into parent Oracle Supply Chain environment. On-time delivery of full process and systems integration." 0 4

AchHead "Oil and Gas R12 Upgrade" "(2015-2016, `$2.5M Budget)"
BodyText "Program Manager for major Oracle R12 upgrade - full Financials, Supply Chain, Service modules plus external application integration portfolio. On-time delivery." 0 4

AchHead "Perficient Corporate Oracle R12" "(2014, `$2M Budget)"
BodyText "Led 20-person global team implementing Perficient's own Oracle R12 platform across US, Canada, China, and India. Go-Live July 2014." 0 4

# GE
EmployerHead "General Electric - GE Transportation Systems, Erie, PA"
RoleLine "Senior IM Program Manager"        "July 2009 - May 2012"
RoleLine "Customer Support IM Leader"       "January 2007 - July 2008"
RoleLine "Commercial IM Leader"             "February 2006 - January 2007"
RoleLine "IM Program Manager, Quality Systems" "June 2004 - February 2006"
RoleLine "Senior Project Leader"            "September 2000 - June 2004"
RoleLine "IM Systems Analyst"               "January 1998 - September 2000"

BodyText "14 years leading technology programs at one of the world's most complex global enterprises. Final role: Senior IM Program Manager responsible for GE Transportation's Oracle ERP global extension strategy." 3 5

Para 2 2 0
$sel.Font.Bold = $true; $sel.Font.Color = $Black
$sel.TypeText("Selected Achievements:")
$sel.TypeParagraph()
ResetFont

AchHead "Global Oracle ERP Extension" "(2008-2012, ~`$17M combined portfolio)"
BodyText "Developed and executed strategy to extend GE Transportation's Oracle ERP instance to Brazil, China, Europe, Kazakhstan, and the US. Delivered consistent global processes across Supply Chain and Finance - reducing total cost of ownership by 50%." 0 3
BulletLine "Brazil Legacy Conversion: `$3M - Oracle Financials/SCM/Manufacturing + Brazil localizations"
BulletLine "China Oracle Implementation: `$2M - including UTF-8 ERP environment upgrade"
BulletLine "Kazakhstan Oracle Implementation: `$3M - full Oracle stack + IT infrastructure"
BulletLine "ICS EMEA Conversion (Italy/UK/Netherlands): `$2.0M"
BulletLine "Battery Business Startup (US Manufacturing): `$3.4M - Oracle + Teamcenter PLM + Proficy MES"

AchHead "CustomerCentral CRM" "(2006-2007)"
BodyText "Launched GE Transportation's CRM platform. Managed `$1M program deck generating `$70M in order management benefits. Presented GE's Digitization Value Story to China's Ministry of Rail at a Technology Summit in Beijing." 0 4

AchHead "eServices Digital Platform" "(2000-2004)"
BodyText "Designed and delivered GE Transportation's eServices platform - servicing 9,000+ locomotives globally and generating `$50M+ in order management benefits. Implemented GE Transportation's first B2B platform with three railroad integrations." 0 4

# Independent
EmployerHead "Independent Oracle Consultant, Erie, PA"
RoleLine "Project Manager" "May 2012 - December 2012"
BodyText "IT project planning and advisory for local businesses and educational institutions." 2 4

# Elias
EmployerHead "Elias Communications, Pittsburgh, PA"
RoleLine "Director of Technical Services" "May 1994 - December 1997"
BodyText "Led consulting practice delivering enterprise internet presence solutions. Full lifecycle: planning, implementation, and ongoing support." 2 4

# Algor
EmployerHead "Algor, Inc., Pittsburgh, PA"
RoleLine "Technical Operations Manager" "March 1992 - May 1994"
BodyText "Managed six-person IT department. Application development, infrastructure, data center." 2 2
RoleLine "Programmer / Analyst" "July 1990 - March 1992"
BodyText "Software testing, code inspection, and development of automated sales and delivery system." 2 4

# ── EDUCATION ─────────────────────────────────────────────────────────────────
SectionHead "Education"
Para 2 1 0
$sel.Font.Bold = $true; $sel.Font.Color = $Black
$sel.TypeText("Bachelor of Science, Computer Science")
$sel.TypeParagraph()
Para 0 4 0
$sel.Font.Bold = $false; $sel.Font.Color = $DkGray
$sel.TypeText("University of Pittsburgh   |   Pittsburgh, PA   |   1990")
$sel.TypeParagraph()
ResetFont

# ── CERTIFICATIONS ────────────────────────────────────────────────────────────
SectionHead "Certifications and Training"
BulletLine "Six Sigma Green Belt   |   BB/Lean Six Sigma"
BulletLine "GE Crotonville - Leadership In Growth (LIG)   |   Advanced Manager Course (AMC)"
BulletLine "Celonis Analyst Certification (in progress)"

# ── BUILT NOT JUST MANAGED ────────────────────────────────────────────────────
SectionHead "Built, Not Just Managed"
BodyText "Meridian - Custom LLM application built on the Anthropic API for Oracle program forecasting and delivery risk prediction. Active internal tool." 0 4
BodyText "Homelab Infrastructure - Dual-server production rack (Dell R730, R740) with OPNsense edge router. Reflects technical depth and hands-on capability unusual at Director level." 0 4

# ── SAVE ──────────────────────────────────────────────────────────────────────
$out = "C:\Users\jeff\My Drive\PKA-Jeffrey\branding\leader-inbox\Jeffrey-Davis-Best-of-Class-Resume-2026.docx"
$doc.SaveAs([ref]$out, [ref]16)
$doc.Close()
$word.Quit()
Write-Output "Saved: $out"
