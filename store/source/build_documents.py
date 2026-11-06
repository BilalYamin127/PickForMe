from pathlib import Path
import json, html, re
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.colors import HexColor
ROOT=Path(__file__).resolve().parents[1]
MAIL='zulqarnain.tech9068@gmail.com'
POLICY_URL='https://bilalyamin127.github.io/PickForMe/privacy-policy/'
NAME='PickForMe: Random Picker'
SHORT='Spin a wheel or shuffle your choices. Make everyday decisions offline.'
FULL='''Too many choices? Give chance a turn.

PickForMe helps you choose what to eat, which movie to watch, what to play, where to go, or who goes first. Add your options, spin the colorful wheel or shuffle a list, and let a little randomness move your day forward.

TWO WAYS TO PICK
• Spin wheel: watch a smooth animated wheel land on your result.
• Shuffle list: see your choices shuffle before the final selection appears.

YOUR CHOICES, READY WHEN YOU ARE
Create a title, add your options, and drag to reorder them. Save lists for later, edit them whenever plans change, or duplicate a favorite list to make something new. Prefer a one-time choice? Pick without saving a list.

A FAIR CHANCE FOR EVERY OPTION
Each option entry has an equal chance of being selected. The winner is chosen before the animation begins, and the wheel stops on that choice. Repeated results are possible, just as they are with a fair random draw.

KEEP THE LITTLE VICTORIES
Look back at your decision history with the result, time and selection mode. Share a winning choice as text through your device’s share sheet, or clear your history whenever you like.

MAKE IT FEEL LIKE YOU
Choose light mode, dark mode or your device’s appearance. Turn sound effects and vibration on or off. Sound and haptic feedback depend on device support and system settings.

OFFLINE AND SIMPLE
No account, no backend, no ads and no in-app purchases in this version. Your lists, results and preferences are stored on your device. Use the decision tools without an internet connection. Sharing through another app follows that app’s connectivity and privacy settings.

Dinner plans, game nights, movie picks, chores and friendly turn-taking: spend less time deciding and more time doing.

PickForMe is designed for everyday choices and entertainment. Use your judgment for important decisions.'''
assert len(NAME)<=30 and len(SHORT)<=80 and len(FULL)<=4000
for filename,text in [('app-name.txt',NAME),('short-description.txt',SHORT),('full-description.txt',FULL),('release-notes.txt','Meet PickForMe! Spin a colorful wheel or shuffle your choices, save reusable lists, revisit recent results, and share your pick. Includes offline storage, light and dark themes, and optional sound and vibration.')]:
 (ROOT/'listing'/filename).write_text(text+'\n')
metadata={"language":"en-US","app_name":NAME,"short_description":SHORT,"category":"Tools","app_type":"App","pricing":"Free","contains_ads":False,"in_app_purchases":False,"support_email":MAIL,"privacy_policy_url":POLICY_URL,"privacy_policy_hosting_status":"requires GitHub Pages activation","website_optional":"","character_counts":{"app_name":len(NAME),"short_description":len(SHORT),"full_description":len(FULL)}}
(ROOT/'listing'/'metadata.json').write_text(json.dumps(metadata,indent=2)+'\n')
POLICY=[
('Privacy Policy for PickForMe','Last updated: 7 November 2026\nDeveloper: Bilal Yamin\nContact: '+MAIL),
('1. About this policy','PickForMe – Random Decision Maker is an offline application for everyday random choices. This policy explains how the current version handles information when you use its wheel, list picker, saved lists, history, settings and sharing feature.'),
('2. Information stored on your device','The app stores the decision titles and options you enter, saved-list identifiers and timestamps, selected results and their timestamps and selection modes, and preferences such as theme, sound and vibration. This information is stored locally using Hive CE. No account or authentication is required.'),
('3. Information we collect','The current app does not send your decision lists, results or preferences to the developer. It has no developer-operated backend, advertising SDK, analytics service, tracking technology or in-app purchase system. We do not collect device identifiers or location through the app. The app does not request access to your contacts, camera, microphone, photos or precise location.'),
('4. How your information is used','Local data is used to display and edit your lists, make random selections, show decision history, and remember your preferences. Random selection is performed on the device. Core decision-making features work offline.'),
('5. Sharing a result','Sharing is optional and starts only when you tap the share action. The app gives the selected result text to your device’s native share sheet. You choose whether to share it and which app or person receives it. The receiving app or service processes that information under its own privacy policy. We do not receive a copy of shared results through a server.'),
('6. Device services and backups','The app uses operating-system services for storage, sound, haptic feedback and the share sheet. Sound and vibration availability depend on your device and settings. Device-level backups or transfers may include app data depending on your operating system and backup settings. Those backups are controlled by you and your device or backup provider, not by a PickForMe server. If you use a browser preview, its hosting provider may process ordinary request information, such as an IP address, to serve the preview; this policy’s offline-app statements describe the native mobile app.'),
('7. Retention and deletion','Saved lists remain on your device until you delete them or clear app data. Deleting a saved list does not automatically delete its earlier history entries. You can clear decision history from History or Settings. To remove all locally stored lists, results and preferences, clear the app’s storage through your device settings or uninstall it; on some devices reinstallation or device restoration may restore a backup. Manage any backups through your device or backup-provider settings.'),
('8. Security','Local app data is kept in the application’s storage area using the protections supplied by the operating system. The current app does not add its own database encryption or require an app passcode. Avoid entering sensitive information into decision titles or options. No method of storage can be guaranteed completely secure.'),
('9. Children','PickForMe is a general-purpose decision tool and does not intentionally collect personal information from children or other users through the app. It does not include accounts, advertising or social profiles. A parent or guardian should supervise sharing through other apps where appropriate.'),
('10. Contacting us','If you email support, your email provider and ours will process the address and information you choose to send. We use that information to respond to your request and do not use it for advertising. Do not include sensitive information in support messages. For privacy questions, contact Bilal Yamin at '+MAIL+'.'),
('11. Changes to this policy','If the app’s data practices change, this policy will be updated and its last-updated date revised. Review the current policy before using a newly released version.'),
]
md='# '+POLICY[0][0]+'\n\n'+POLICY[0][1]+'\n\n'+'\n\n'.join('## '+h+'\n\n'+b for h,b in POLICY[1:])+'\n'
(ROOT/'privacy-policy'/'privacy-policy.md').write_text(md)
legal=ROOT.parent/'assets'/'legal'
legal.mkdir(parents=True,exist_ok=True)
(legal/'privacy-policy.md').write_text(md)
(ROOT/'privacy-policy'/'publication-notes.txt').write_text('Public support email: '+MAIL+'\nPrivacy policy URL: '+POLICY_URL+'\nKeep the hosted page and in-app bundled policy synchronized when updating data practices. Confirm the live URL before submitting a release.\n')
body=''.join('<section><h2>'+html.escape(h)+'</h2><p>'+html.escape(b).replace('\n','<br>')+'</p></section>' for h,b in POLICY[1:])
page='''<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>PickForMe Privacy Policy</title><meta name="description" content="How PickForMe handles locally stored decisions and optional result sharing."><style>:root{color-scheme:light}*{box-sizing:border-box}body{margin:0;background:#faf8ff;color:#282136;font:16px/1.75 system-ui,sans-serif}main{max-width:820px;margin:auto;padding:60px 24px 80px}.brand{color:#7653cf;font-weight:800;letter-spacing:1px}h1{font-size:clamp(32px,6vw,48px);line-height:1.15;letter-spacing:-1.5px}h2{font-size:21px;line-height:1.35;margin:32px 0 10px}p{margin:0 0 16px}.meta{color:#625770;padding-bottom:24px;border-bottom:1px solid #e4ddef}a{color:#6542bb}</style></head><body><main><div class="brand">✳ PickForMe</div><h1>Privacy Policy</h1><p class="meta">'''+html.escape(POLICY[0][1]).replace('\n','<br>')+'</p>'+body+'</main></body></html>'
(ROOT/'privacy-policy'/'index.html').write_text(page)
public_policy=ROOT.parent/'docs'/'privacy-policy'
public_policy.mkdir(parents=True,exist_ok=True)
(public_policy/'index.html').write_text(page)
(ROOT.parent/'docs'/'.nojekyll').touch()
# Rich editable documents and PDFs, all from the same source.
def export(title,sections,folder,stem):
 d=Document();d.sections[0].header.paragraphs[0].text='PICKFORME  /  PUBLISHING KIT'
 style=d.styles['Normal'];style.font.name='Calibri';style.font.size=Pt(11)
 style.font.color.rgb=RGBColor.from_string('30273E')
 d.add_heading(title,0)
 for heading,text in sections:
  d.add_heading(heading,level=1)
  for paragraph in text.split('\n\n'): d.add_paragraph(paragraph)
 d.save(str(folder/(stem+'.docx')))
 styles=getSampleStyleSheet();styles.add(ParagraphStyle(name='KitTitle',parent=styles['Title'],fontSize=26,leading=31,textColor=HexColor('#5633a2'),spaceAfter=22))
 styles['Heading2'].textColor=HexColor('#6544ab');styles['BodyText'].leading=15;styles['BodyText'].spaceAfter=10
 story=[Paragraph(html.escape(title),styles['KitTitle'])]
 for heading,text in sections:
  story.append(Paragraph(html.escape(heading),styles['Heading2']))
  for paragraph in text.split('\n\n'):story.append(Paragraph(html.escape(paragraph).replace('\n','<br/>'),styles['BodyText']))
  story.append(Spacer(1,7))
 def footer(c,doc):c.setFont('Helvetica',8);c.setFillColor(HexColor('#756b80'));c.drawString(46,28,'PickForMe | Publishing kit');c.drawRightString(548,28,str(doc.page))
 SimpleDocTemplate(str(folder/(stem+'.pdf')),title='PickForMe — '+title,author='Bilal Yamin',subject='PickForMe publishing assets',pagesize=(595.28,841.89),leftMargin=46,rightMargin=46,topMargin=48,bottomMargin=48).build(story,onFirstPage=footer,onLaterPages=footer)
export('Privacy Policy',POLICY,ROOT/'privacy-policy','privacy-policy')
LISTING=[('Store details',f'App name: {NAME}\nDefault language: English (United States)\nApp category: Tools\nApp type: App\nPrice: Free\nContains ads: No\nIn-app purchases: No\nSupport email: {MAIL}\nPrivacy policy URL: {POLICY_URL}'),('Short description',SHORT),('Full description',FULL),('Release notes',(ROOT/'listing'/'release-notes.txt').read_text()),('Suggested search language','Natural phrases already included in the copy: random picker, spin wheel, decision maker, shuffle list, offline choices. Google Play has no separate keyword field. Avoid repeating keywords or adding ranking claims.'),('Asset upload order','01: Home / everyday decisions\n02: Create and reorder choices\n03: Spin wheel\n04: Shuffle list\n05: Result and sharing\n06: Reusable saved lists\n07: Dark appearance and preferences'),('Publication details',f'Public support email: {MAIL}. Privacy policy: {POLICY_URL}. Confirm the URL is live before submission. Closed-testing tester addresses are kept separately from this public listing. Recheck the policy and listing if app features or SDKs change.')]
(ROOT/'listing'/'complete-store-listing.md').write_text('# PickForMe — Complete Store Listing\n\n'+'\n\n'.join('## '+h+'\n\n'+b for h,b in LISTING)+'\n')
export('Complete Store Listing',LISTING,ROOT/'listing','complete-store-listing')
