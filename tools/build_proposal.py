"""Render the revised Markdown proposal to PDF (requires reportlab).

This small renderer handles this proposal's headings, tables and four equations.
Edit the Markdown as the primary source; update EQUATIONS if its maths changes.
Usage: python tools/build_proposal.py
"""
from html import escape
from pathlib import Path
import re

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_JUSTIFY
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, KeepTogether, PageBreak,
)

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "proposal" / "Peinan_Gu_Feedback_Two.md"
OUTPUT = ROOT / "output" / "pdf" / "Peinan_Gu_Feedback_Two.pdf"

# Prefer embedded Times New Roman; ReportLab's bundled Vera is a portable fallback.
import reportlab
font_dir = Path("/System/Library/Fonts/Supplemental")
if (font_dir / "Times New Roman.ttf").exists():
    variants = {"": "Times New Roman.ttf", "-Bold": "Times New Roman Bold.ttf",
                "-Italic": "Times New Roman Italic.ttf",
                "-BoldItalic": "Times New Roman Bold Italic.ttf"}
else:
    font_dir = Path(reportlab.__file__).parent / "fonts"
    variants = {"": "Vera.ttf", "-Bold": "VeraBd.ttf",
                "-Italic": "VeraIt.ttf", "-BoldItalic": "VeraBI.ttf"}
for suffix, filename in variants.items():
    pdfmetrics.registerFont(TTFont("Proposal" + suffix, str(font_dir / filename)))
pdfmetrics.registerFontFamily("Proposal", normal="Proposal", bold="Proposal-Bold",
                            italic="Proposal-Italic", boldItalic="Proposal-BoldItalic")

base = dict(fontName="Proposal", fontSize=11.2, leading=15, spaceAfter=7)
body = ParagraphStyle("Body", alignment=TA_JUSTIFY, **base)
small = ParagraphStyle("Small", fontName="Proposal", fontSize=9.4, leading=12.3,
                       spaceAfter=6)
heading = ParagraphStyle("Heading", fontName="Proposal-Bold", fontSize=13,
                         leading=16, spaceBefore=12, spaceAfter=7, keepWithNext=True)
title = ParagraphStyle("Title", fontName="Proposal-Bold", fontSize=18,
                       leading=21, alignment=TA_CENTER, spaceAfter=12)
subtitle = ParagraphStyle("Subtitle", fontName="Proposal-Bold", fontSize=13.7,
                          leading=17, alignment=TA_CENTER, spaceAfter=12)
centre = ParagraphStyle("Centre", fontName="Proposal", fontSize=11,
                        leading=14.5, alignment=TA_CENTER, spaceAfter=3)
quote = ParagraphStyle("Question", fontName="Proposal-Italic", fontSize=11,
                       leading=14.5, leftIndent=14, rightIndent=14, spaceAfter=9)
equation = ParagraphStyle("Equation", fontName="Proposal", fontSize=10.5,
                          leading=16, alignment=TA_CENTER, spaceAfter=7)

EQUATIONS = [
    'x<sub>m</sub>[n] = h<sub>s,m</sub>[n] * s[n] + '
    'h<sub>i,m</sub>[n] * i[n] + v<sub>m</sub>[n]. &nbsp; (1)',
    'Q<sub>k,l</sub> = αQ<sub>k,l-1</sub> + (1-α)|Y<sub>k,l</sub>|<super>2</super>, '
    '&nbsp; P<sub>s,k,l</sub> = max(Q<sub>k,l</sub> - P<sub>n,k</sub>, 0). &nbsp; (2)',
    'ξ<sub>b,l</sub> = P<sub>s,b,l</sub> / max(P<sub>n,b</sub>, ε), '
    '&nbsp; G<sub>b,l</sub> = ξ<sub>b,l</sub> / (1 + ξ<sub>b,l</sub>). &nbsp; (3)',
    'SNR<sub>e</sub>(y) = 10 log<sub>10</sub>'
    '(||s<sub>ref</sub>||<super>2</super> / ||s<sub>ref</sub>-y||<super>2</super>),<br/>'
    'ΔSNR<sub>e</sub> = SNR<sub>e</sub>(y) - SNR<sub>e</sub>(x<sub>ref</sub>). &nbsp; (4)',
]


def inline(text):
    text = escape(text)
    text = re.sub(r"\*\*(.*?)\*\*", r"<b>\1</b>", text)
    text = re.sub(r"https://[^\s<]+", lambda m: (
        f'<link href="{m[0]}" color="#25445c">{m[0]}</link>'), text)
    return text


def footer(canvas, doc):
    canvas.saveState()
    canvas.setStrokeColor(colors.HexColor("#bbbbbb"))
    canvas.setLineWidth(0.4)
    canvas.line(51, 44, A4[0] - 51, 44)
    canvas.setFont("Proposal", 9)
    canvas.setFillColor(colors.HexColor("#555555"))
    canvas.drawString(51, 31, "ELEC5305 | Peinan Gu | 530679835")
    canvas.drawRightString(A4[0] - 51, 31, str(doc.page))
    canvas.restoreState()


def build():
    lines = SOURCE.read_text(encoding="utf-8").splitlines()
    story, i, eq_index = [], 0, 0
    in_references = False
    while i < len(lines):
        line = lines[i].strip()
        if not line or line == "---":
            i += 1
            continue
        if line == "$$":
            i += 1
            while lines[i].strip() != "$$":
                i += 1
            story.append(KeepTogether([Paragraph(EQUATIONS[eq_index], equation)]))
            eq_index += 1
        elif line.startswith("| Item") or line.startswith("| Weeks"):
            rows = []
            while i < len(lines) and lines[i].strip().startswith("|"):
                cells = [c.strip() for c in lines[i].strip().strip("|").split("|")]
                if not all(re.fullmatch(r"[-:]+", c) for c in cells):
                    rows.append([Paragraph(inline(c), small) for c in cells])
                i += 1
            width = A4[0] - 102
            first = 124 if "Item" in line else 75
            table = Table(rows, colWidths=[first, width - first], repeatRows=1,
                          hAlign="LEFT")
            table.setStyle(TableStyle([
                ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#eeeeee")),
                ("GRID", (0, 0), (-1, -1), 0.4, colors.HexColor("#bbbbbb")),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("LEFTPADDING", (0, 0), (-1, -1), 7),
                ("RIGHTPADDING", (0, 0), (-1, -1), 7),
                ("TOPPADDING", (0, 0), (-1, -1), 5),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
            ]))
            story.extend([table, Spacer(1, 8)])
            continue
        elif line.startswith("# "):
            story.append(Paragraph(inline(line[2:]), title))
        elif line.startswith("## "):
            content = line[3:]
            numbered = bool(re.match(r"\d\.", content))
            in_references = content.startswith("7.")
            if content.startswith(("3.", "7.")):
                story.append(PageBreak())
            story.append(Paragraph(inline(content), heading if numbered else subtitle))
        elif line.startswith("**Student") or line.startswith("**GitHub"):
            story.append(Paragraph(inline(line), centre))
        elif line.startswith("> "):
            story.append(Paragraph(inline(line[2:]), quote))
        else:
            paragraph = [line]
            while i + 1 < len(lines) and lines[i + 1].strip():
                if lines[i + 1].startswith(("#", "|", "$$", "---")):
                    break
                i += 1
                paragraph.append(lines[i].strip())
            text = " ".join(paragraph)
            story.append(Paragraph(inline(text), small if in_references else body))
        i += 1
    assert eq_index == len(EQUATIONS), "Update equation renderings after source changes."
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    document = SimpleDocTemplate(
        str(OUTPUT), pagesize=A4, rightMargin=51, leftMargin=51,
        topMargin=45, bottomMargin=58,
        title="ELEC5305 Project Proposal - Revised",
        author="Peinan Gu", subject="Controlled comparison of Wiener post-filter smoothing",
    )
    document.build(story, onFirstPage=footer, onLaterPages=footer)
    print(OUTPUT)


if __name__ == "__main__":
    build()
