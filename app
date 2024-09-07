import tkinter as tk
from tkinter import messagebox
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfbase import pdfmetrics
from datetime import datetime

# Register the Tahoma and Tahoma-Bold fonts
def register_fonts():
    pdfmetrics.registerFont(TTFont('Tahoma', 'Tahoma.ttf'))
    pdfmetrics.registerFont(TTFont('Tahoma-Bold', 'Tahoma-Bold.ttf'))

def generate_pdf(lab_report_no, date, project_id, project, sample_identification, quantity_represented, sampled_at, orig_source, supplied_by, proposed_use, spec_item_no, sampled_by_name, sampled_by_office, sampled_by_date, submitted_by_name, submitted_by_office, submitted_by_date):
    # Get the current date and time
    now = datetime.now()
    timestamp = now.strftime("%Y%m%d_%H%M%S")
    
    # Create the filename with lab_report_no and timestamp
    file_name = f"{lab_report_no}_{timestamp}.pdf"
    
    # Create the PDF
    c = canvas.Canvas(file_name, pagesize=letter)
    width, height = letter
    
    # Register the fonts
    register_fonts()
    
    # Draw the image (now using a .jpg file)
    image_path = "logo.jpg"  # Replace with your image file path
    image_x = 50
    image_y = height - 90
    image_width = 50
    image_height = 50
    c.drawImage(image_path, image_x, image_y, width=image_width, height=image_height)
    
    # Header text
    header_lines = [
        "Republic of the Philippines",
        "DEPARTMENT OF PUBLIC WORKS AND HIGHWAYS",
        "REGIONAL OFFICE VI",  # This line will be bold
        "Fort San Pedro, Iloilo City"
    ]
    
    # Set the font for the header
    c.setFont("Tahoma", 10)
    
    # Calculate the vertical position for the header, adjusting for the image
    header_y = height - 50
    
    # Adjust the x-position of the text to make room for the image
    text_x_offset = image_x + image_width + 10
    
    # Draw the header text, centered
    for i, line in enumerate(header_lines):
        # Use bold font for "REGIONAL OFFICE VI"
        if line == "REGIONAL OFFICE VI":
            c.setFont("Tahoma-Bold", 10)
        else:
            c.setFont("Tahoma", 10)
            
        text_width = c.stringWidth(line, "Tahoma", 10)
        x_position = (width - text_width) / 2
        
        # Adjust the x-position if it overlaps with the image
        if (x_position < text_x_offset):
            x_position = text_x_offset
        
        c.drawString(x_position, header_y - (i * 12), line)  # Adjusted line spacing to 12 units
    
    # Add the "MTS Form No. 12" line aligned to the right
    form_text = "MTS Form No. 12"
    form_text_width = c.stringWidth(form_text, "Tahoma", 10)
    c.drawString(width - form_text_width - 35, header_y - 60, form_text)  # Adjusted position
    
    # Add the "Lab. Report No.:" and "Date:" lines below "MTS Form No. 12"
    lab_report_no_text = f"Lab. Report No.: {lab_report_no}"
    date_text = f"Date: {date}"
    
    c.setFont("Tahoma", 10)
    c.drawString(width - form_text_width - 100, header_y - 80, lab_report_no_text)
    c.drawString(width - form_text_width - 100, header_y - 92, date_text)
    
    # Define page margins and positioning
    margin_left = 36  # 0.5 inches in points
    right_margin = 576  # 8 inches wide (letter size), so the right margin is 576 points (72 points/inch)
    line_height = 12
    field_y_start = header_y - 110  # Starting Y position for the fields

    # Function to wrap and justify text
    def draw_wrapped_text(c, x, y, text, width_limit, line_height, justify=False):
        words = text.split(' ')
        lines = []
        current_line = ""

        for word in words:
            test_line = current_line + (word if current_line == "" else f" {word}")
            if c.stringWidth(test_line, "Tahoma", 10) <= width_limit:
                current_line = test_line
            else:
                lines.append(current_line)
                current_line = word
        
        lines.append(current_line)  # Append the last line

        # Draw lines
        for i, line in enumerate(lines):
            if justify and i < len(lines) - 1:
                # Justify the text, i.e., distribute the extra space evenly between words
                justified_line = justify_text(c, line, width_limit)
                c.drawString(x, y - (i * line_height), justified_line)
            else:
                c.drawString(x, y - (i * line_height), line)

        return len(lines) * line_height  # Return the total height used

    # Helper function to justify a single line of text
    def justify_text(c, line, width_limit):
        words = line.split(' ')
        if len(words) == 1:
            return line  # No justification needed for single word lines

        total_width = c.stringWidth(line, "Tahoma", 10)
        extra_space = (width_limit - total_width) / (len(words) - 1)

        justified_line = ""
        for i, word in enumerate(words):
            justified_line += word
            if i < len(words) - 1:
                justified_line += " " * int(extra_space / c.stringWidth(' ', "Tahoma", 10))
        
        return justified_line

    # Fields to be displayed
    fields = [
        ("Project ID No.", project_id),
        ("Project", project),
        ("Sample Identification", sample_identification),
        ("Quantity Represented", quantity_represented),
        ("Sample at", sampled_at),
        ("Original Source", orig_source),
        ("Supplied By", supplied_by),
        ("Proposed Use", proposed_use),
        ("Spec's Item No.", spec_item_no)
    ]
    
    # Draw the fields with wrapping and justification
    for i, (label, value) in enumerate(fields):
        # Draw the label
        label_y = field_y_start - (i * line_height)
        c.drawString(margin_left, label_y, label)

        # Draw the colon
        colon_x = margin_left + 150  # 150 points is the space reserved for labels
        c.drawString(colon_x, label_y, ":")

        # Draw the value, wrapped and justified
        value_x = colon_x + 10  # Indent after colon
        text_height_used = draw_wrapped_text(c, value_x, label_y, value, right_margin - value_x, line_height, justify=True)

        # Adjust the y position for multi-line text fields
        field_y_start -= (text_height_used - line_height)

    # Add "Sampled By" and "Submitted By" fields
    sampled_submitted_fields = [
        ("Sampled By", sampled_by_name, sampled_by_office, sampled_by_date),
        ("Submitted By", submitted_by_name, submitted_by_office, submitted_by_date)
    ]
    

    # Calculate available width for each column (Name, Office, Date)
    available_width = width - margin_left * 2  # Full available width within the margins
    col_width = available_width / 3  # Divide the available width into three equal columns

    for i, (label, name, office, date) in enumerate(sampled_submitted_fields):
        label_y = field_y_start - (i * 2 * line_height)
        c.drawString(margin_left, label_y, label)

        colon_x = margin_left + 150
        c.drawString(colon_x, label_y, ":")

        # Draw the name, office, and date in their respective columns
        name_x = colon_x + 10
        office_x = name_x + col_width
        date_x = office_x + col_width

        c.drawString(name_x, label_y, name)
        c.drawString(office_x, label_y, office)
        c.drawString(date_x, label_y, date)

        # Draw the underlines without exceeding the right margin
        underline_y = label_y - 2

        # Ensure that the underlines do not exceed the right margin
        name_underline_end = min(name_x + col_width, right_margin)
        office_underline_end = min(office_x + col_width, right_margin)
        date_underline_end = min(date_x + col_width, right_margin)

    c.line(name_x, underline_y, name_underline_end, underline_y)
    c.line(office_x, underline_y, office_underline_end, underline_y)
    c.line(date_x, underline_y, date_underline_end, underline_y)

    # Save the PDF
    c.save()
    
    # Show a message box to indicate that the PDF has been generated
    messagebox.showinfo("PDF Generated", f"PDF '{file_name}' has been created!")


def submit_form():
    lab_report_no = entry_lab_report_no.get()
    date = entry_date.get()
    project_id = entry_project_id.get()
    project = entry_project.get()
    sample_identification = entry_sample_identification.get()
    quantity_represented = entry_quantity_represented.get()
    sampled_at = entry_sampled_at.get()
    orig_source = entry_orig_source.get()
    supplied_by = entry_supplied_by.get()
    proposed_use = entry_proposed_use.get()
    spec_item_no = entry_spec_item_no.get()
    sampled_by_name = entry_sampled_by_name.get()
    sampled_by_office = entry_sampled_by_office.get()
    sampled_by_date = entry_sampled_by_date.get()
    submitted_by_name = entry_submitted_by_name.get()
    submitted_by_office = entry_submitted_by_office.get()
    submitted_by_date = entry_submitted_by_date.get()
    generate_pdf(lab_report_no, date, project_id, project, sample_identification, quantity_represented, sampled_at, orig_source, supplied_by, proposed_use, spec_item_no, sampled_by_name, sampled_by_office, sampled_by_date, submitted_by_name, submitted_by_office, submitted_by_date)

# Create the main window
root = tk.Tk()
root.title("Project Test Result Form")

# Create and place labels and entries for user input
labels = [
    "Lab. Report No.:",
    "Date:",
    "Project ID No.:",
    "Project:",
    "Sample Identification:",
    "Quantity Represented:",
    "Sample at:",
    "Original Source:",
    "Supplied By:",
    "Proposed Use:",
    "Spec's Item No.:",
    "Sampled By:",
    "Submitted By:"
]

entries = [
    "entry_lab_report_no",
    "entry_date",
    "entry_project_id",
    "entry_project",
    "entry_sample_identification",
    "entry_quantity_represented",
    "entry_sampled_at",
    "entry_orig_source",
    "entry_supplied_by",
    "entry_proposed_use",
    "entry_spec_item_no",
    "entry_sampled_by_name",
    "entry_sampled_by_office",
    "entry_sampled_by_date",
    "entry_submitted_by_name",
    "entry_submitted_by_office",
    "entry_submitted_by_date"
]

# Create and place labels and entries
max_label_width = 0
for label in labels:
    label_width = tk.Label(root, text=label).winfo_reqwidth()
    if label_width > max_label_width:
        max_label_width = label_width

for i, (label_text, entry_name) in enumerate(zip(labels, entries)):
    if label_text == "Sampled By:":
        tk.Label(root, text=label_text).grid(row=i, column=0, padx=10, pady=10, sticky='w')
        entry1 = tk.Entry(root)
        entry1.grid(row=i, column=1, padx=5, pady=10, sticky='w')
        entry2 = tk.Entry(root)
        entry2.grid(row=i, column=2, padx=5, pady=10, sticky='w')
        entry3 = tk.Entry(root)
        entry3.grid(row=i, column=3, padx=5, pady=10, sticky='w')
        globals()["entry_sampled_by_name"] = entry1
        globals()["entry_sampled_by_office"] = entry2
        globals()["entry_sampled_by_date"] = entry3
    elif label_text == "Submitted By:":
        tk.Label(root, text=label_text).grid(row=i, column=0, padx=10, pady=10, sticky='w')
        entry1 = tk.Entry(root)
        entry1.grid(row=i, column=1, padx=5, pady=10, sticky='w')
        entry2 = tk.Entry(root)
        entry2.grid(row=i, column=2, padx=5, pady=10, sticky='w')
        entry3 = tk.Entry(root)
        entry3.grid(row=i, column=3, padx=5, pady=10, sticky='w')
        globals()["entry_submitted_by_name"] = entry1
        globals()["entry_submitted_by_office"] = entry2
        globals()["entry_submitted_by_date"] = entry3
    else:
        tk.Label(root, text=label_text).grid(row=i, column=0, padx=10, pady=10, sticky='w')
        entry = tk.Entry(root)
        entry.grid(row=i, column=1, padx=10, pady=10, sticky='w')
        globals()[entry_name] = entry

# Create and place the submit button
submit_button = tk.Button(root, text="Generate PDF", command=submit_form)
submit_button.grid(row=len(labels), columnspan=4, pady=20)

# Register fonts and start the Tkinter main loop
register_fonts()
root.mainloop()
