#!/usr/bin/env python3
"""Generate a simple PDF from docs/manual_test_guide.md using reportlab.
If reportlab is not installed, the script will attempt to install it via pip for the current interpreter.
"""
import sys
import subprocess
import os

try:
    from reportlab.lib.pagesizes import letter
    from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Preformatted
    from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
    from reportlab.lib.units import inch
    from reportlab.lib import colors
except ImportError:
    print("reportlab not found, installing...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "reportlab"])  # may require internet
    from reportlab.lib.pagesizes import letter
    from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Preformatted
    from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
    from reportlab.lib.units import inch
    from reportlab.lib import colors

SRC_MD = os.path.join(os.path.dirname(__file__), '..', 'docs', 'manual_test_guide.md')
OUT_PDF = os.path.join(os.path.dirname(__file__), '..', 'docs', 'manual_test_guide.pdf')

styles = getSampleStyleSheet()
if 'Code' not in styles:
    styles.add(ParagraphStyle(name='Code', fontName='Courier', fontSize=9, leading=11))
if 'Heading' not in styles:
    styles.add(ParagraphStyle(name='Heading', fontSize=16, leading=18, spaceAfter=6))
if 'NormalSpace' not in styles:
    styles.add(ParagraphStyle(name='NormalSpace', spaceAfter=6))

def parse_markdown_simple(md_text):
    """Very small markdown -> flowables parser.
    Supports headings (# ), code blocks fenced with ``` and regular paragraphs.
    """
    lines = md_text.splitlines()
    flowables = []
    i = 0
    in_code = False
    code_lines = []
    para_lines = []
    while i < len(lines):
        line = lines[i]
        if line.strip().startswith('```'):
            if in_code:
                # end code block
                flowables.append(Preformatted('\n'.join(code_lines), styles['Code']))
                code_lines = []
                in_code = False
            else:
                # flush paragraph
                if para_lines:
                    flowables.append(Paragraph(' '.join([l.strip() for l in para_lines]), styles['NormalSpace']))
                    para_lines = []
                in_code = True
            i += 1
            continue
        if in_code:
            code_lines.append(line)
            i += 1
            continue
        # not in code block
        if line.strip() == '':
            if para_lines:
                flowables.append(Paragraph(' '.join([l.strip() for l in para_lines]), styles['NormalSpace']))
                para_lines = []
            i += 1
            continue
        if line.startswith('#'):
            # heading
            text = line.lstrip('#').strip()
            if para_lines:
                flowables.append(Paragraph(' '.join([l.strip() for l in para_lines]), styles['NormalSpace']))
                para_lines = []
            flowables.append(Paragraph(text, styles['Heading']))
            i += 1
            continue
        # normal line
        para_lines.append(line)
        i += 1
    # flush
    if code_lines:
        flowables.append(Preformatted('\n'.join(code_lines), styles['Code']))
    if para_lines:
        flowables.append(Paragraph(' '.join([l.strip() for l in para_lines]), styles['NormalSpace']))
    return flowables


def build_pdf():
    with open(SRC_MD, 'r', encoding='utf-8') as f:
        md = f.read()
    doc = SimpleDocTemplate(OUT_PDF, pagesize=letter,
                            rightMargin=72, leftMargin=72,
                            topMargin=72, bottomMargin=72)
    flowables = parse_markdown_simple(md)
    flowables.insert(0, Spacer(1, 0.2*inch))
    doc.build(flowables)
    print(f"Wrote PDF: {OUT_PDF}")

if __name__ == '__main__':
    build_pdf()
