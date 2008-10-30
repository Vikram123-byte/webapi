#!/usr/bin/python
# As you can see in the source code this script makes a number of assumptions.
# Among others it assumes the input is "valid" where "valid" is undefined. It
# also creates dataloss and isn't exactly the best Python script out there.
# Patches accepted!
#
# Usage:
#   cat file-reference | python disposition-of-comments2html.py > output-file

import sys;
import re;
import urllib;

def getLinkDetails(line):
    line = line.split(" ", 1)
    details = ""
    if not (line[-1].startswith("http://") or line[-1].startswith("data:")):
        details = line[1]
    return (line[0], details)

def getMailDetails(url):
    author = ""
    subject = ""
    f = urllib.urlopen(url)
    for line in f:
        if line.startswith('<meta name="Author" content="'):
            author = line.split('"')[3]
        if line.startswith('<meta name="Subject" content="'):
            subject = line.split('"')[3]
            break
    return (author, subject)

def getThreadDetails(lines, i):
    subject = ""
    commentor = ""
    links = []
    conclusion = ""
    n = 0
    while lines[i + n].startswith("   http://") or lines[i + n].startswith("   data:"):
        if n == 0:
            url = lines[i + n][3:]
            if url.startswith("http"):
                commentor, subject = getMailDetails(url)
        links.append(getLinkDetails(lines[i + n][3:]))
        n += 1
    if not lines[i + n].startswith("\n"):
        conclusion = lines[i + n]
    return (subject, commentor, links, conclusion)

def getCommentDetails(lines, i, number):
    summary = ""
    status = ""
    subject = ""
    commentor = ""
    links = []
    conclusion = ""
    n = 0
    while lines[i + n]:
        line = lines[i + n]
        if line.startswith("Summary"):
            summary = line[9:]
            x = 1
            while not (lines[i + n + x].startswith("Status") or
                lines[i + n + x].startswith("Thread")):
                summary += lines[i + n + x]
                x += 1
        if line.startswith("Status"):
            status = line[8:]
            x = 1
            while not lines[i + n + x].startswith("Thread"):
                status += lines[i + n + x]
                x += 1
        if line.startswith("Thread"):
            subject, commentor, links, conclusion = getThreadDetails(lines, i + n + 1)
        try:
            if lines[i + n + 1].startswith("Comment "):
                break
        except:
            break
        n += 1
    return {
        "number": number,
        "subject": subject,
        "summary": summary,
        "status": status,
        "commentor": commentor,
        "links": links,
        "conclusion": conclusion
    }

def getCommentsDetails(lines):
    commentCheck = re.compile(r'Comment \d+\.')
    result = []
    for i in range(0, len(lines) -1, 1):
        if(commentCheck.match(lines[i])):
            number = lines[i].strip("Comment. \n\r")
            result.append(getCommentDetails(lines, i, number))
    return result

def formatComments(lines):
    comments = getCommentsDetails(lines)
    result = ""
    commentTemplate = """  <div>
   <h2>%s</h2>%s%s%s
   <ul>
%s   </ul>%s
  </div>
""" 
    linksTemplate = """    <li><a href="%s">%s</a>%s</li>
"""
    for comment in comments:
        heading = comment["number"] + ". " + comment["subject"]
        commentor = ""
        summary = ""
        status = ""
        links = ""
        conclusion = ""
        if comment["commentor"]:
            commentor = "\n   <p>By: %s</p>" % comment["commentor"]
        if comment["summary"]:
            summary = "\n   <p>Summary: %s</p>" % comment["summary"]
        if comment["status"]:
            status = "\n   <p>Status: %s</p>" % comment["status"]
        for link in comment["links"]:
            details = ""
            if link[1]:
                details = " " + link[1]
            links += linksTemplate % (link[0], link[0], details)
        if comment["conclusion"]:
            conclusion = "\n   <p><strong>%s</strong></p>" % comment["conclusion"]
        result += commentTemplate % (heading, commentor, summary, status, links, conclusion)
    return result

def dispositionOfComments(input):
    template = """<!DOCTYPE html>
<html lang="en">
 <head>
  <meta charset="UTF-8">
  <title>Selectors API Disposition of Comments</title>
 </head>
 <body>
  <h1>Selectors API Disposition of Comments</h2>
  <p>Issues are marked as follows:
  <dl>
   <dt>REJECTED</dt>
    <dd>reviewer's comment was rejected, but reviewer didn't respond</dd>
   <dt>AGREED</dt>
    <dd>reviewer's comment was accepted, but reviewer didn't respond</dd>
   <dt>PENDING FURTHER COMMENT</dt>
    <dd>reviewer needs to comment further before issue can be addressed</dd>
   <dt>CLOSED BY REVIEWER</dt>
    <dd>reviewer explicitly closed the issue without disagreement</dd>
   <dt>POTENTIAL FORMAL OBJECTION</dt>
    <dd>reviewer disagreed with response once, but did not follow up</dd>
   <dt>FORMAL OBJECTION</dt>
    <dd>reviewer disagreed with all responses</dd>
  </dl>
  <hr>
%s </body>
</html>
"""
    return template % formatComments(input)

class NoAuthURLOpener(urllib.FancyURLopener):
    def prompt_user_passwd(a,b,c):
        return ['', '']

urllib._urlopener = NoAuthURLOpener()
sys.stdout.write(dispositionOfComments(sys.stdin.read().splitlines()))
