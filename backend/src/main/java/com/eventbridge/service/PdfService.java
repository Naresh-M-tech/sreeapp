package com.eventbridge.service;

import com.eventbridge.model.OdRequest;
import com.lowagie.text.*;
import com.lowagie.text.pdf.PdfWriter;
import org.springframework.stereotype.Service;
import java.io.ByteArrayOutputStream;
import java.time.format.DateTimeFormatter;

@Service
public class PdfService {
    public byte[] generateOdLetter(OdRequest od) {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        Document doc = new Document(PageSize.A4, 50, 50, 50, 50);
        PdfWriter.getInstance(doc, out);
        doc.open();
        Font titleFont = new Font(Font.HELVETICA, 18, Font.BOLD);
        Font bodyFont = new Font(Font.HELVETICA, 12, Font.NORMAL);
        Font boldFont = new Font(Font.HELVETICA, 12, Font.BOLD);
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd-MM-yyyy");

        doc.add(new Paragraph("EVENT BRIDGE", titleFont));
        doc.add(new Paragraph("ON-DUTY LETTER", new Font(Font.HELVETICA, 16, Font.BOLD)));
        doc.add(new Paragraph(" "));
        doc.add(new Paragraph("Date: " + java.time.LocalDate.now().format(fmt), bodyFont));
        doc.add(new Paragraph(" "));
        doc.add(new Paragraph("Student Name: " + od.getStudentName(), boldFont));
        doc.add(new Paragraph("Roll Number: " + od.getStudentRollNumber(), bodyFont));
        doc.add(new Paragraph("Department: " + od.getDepartment(), bodyFont));
        doc.add(new Paragraph(" "));
        doc.add(new Paragraph("Event: " + od.getEventTitle(), boldFont));
        doc.add(new Paragraph("From: " + (od.getFromDate() != null ? od.getFromDate().format(fmt) : "N/A"), bodyFont));
        doc.add(new Paragraph("To: " + (od.getToDate() != null ? od.getToDate().format(fmt) : "N/A"), bodyFont));
        doc.add(new Paragraph("Reason: " + od.getReason(), bodyFont));
        doc.add(new Paragraph(" "));
        doc.add(new Paragraph("Status: " + od.getStatus().name(), boldFont));
        if (od.getRemarks() != null) doc.add(new Paragraph("Remarks: " + od.getRemarks(), bodyFont));
        doc.add(new Paragraph(" "));
        doc.add(new Paragraph("Approved by: " + (od.getFacultyName() != null ? od.getFacultyName() : "Pending"), bodyFont));
        doc.close();
        return out.toByteArray();
    }

    public byte[] generateCertificate(String userName, String eventTitle, String certType) {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        Document doc = new Document(PageSize.A4.rotate(), 50, 50, 50, 50);
        PdfWriter.getInstance(doc, out);
        doc.open();
        Font titleFont = new Font(Font.HELVETICA, 36, Font.BOLD);
        Font subFont = new Font(Font.HELVETICA, 18, Font.NORMAL);
        Font nameFont = new Font(Font.HELVETICA, 28, Font.BOLD);

        Paragraph title = new Paragraph("CERTIFICATE OF " + certType.toUpperCase(), titleFont);
        title.setAlignment(Element.ALIGN_CENTER);
        doc.add(title);
        doc.add(new Paragraph(" "));
        Paragraph sub = new Paragraph("This is to certify that", subFont);
        sub.setAlignment(Element.ALIGN_CENTER);
        doc.add(sub);
        doc.add(new Paragraph(" "));
        Paragraph name = new Paragraph(userName, nameFont);
        name.setAlignment(Element.ALIGN_CENTER);
        doc.add(name);
        doc.add(new Paragraph(" "));
        Paragraph ev = new Paragraph("has participated in " + eventTitle, subFont);
        ev.setAlignment(Element.ALIGN_CENTER);
        doc.add(ev);
        doc.add(new Paragraph(" "));
        doc.add(new Paragraph("Event Bridge", new Font(Font.HELVETICA, 14, Font.ITALIC)));
        doc.close();
        return out.toByteArray();
    }
}
