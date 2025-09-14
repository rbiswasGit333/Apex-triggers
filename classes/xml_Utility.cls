public with sharing class xml_Utility {
    public static String Xmldata;
    public static String da;
    
    @AuraEnabled(cacheable=true)
    public static void recordList() {
        Dom.Document doc = new Dom.Document();
        Dom.XmlNode root = doc.createRootElement('College', null,null);
        Dom.XmlNode root2 = root.addChildElement('Departments', null,null);
        Dom.XmlNode root3 = root2.addChildElement('Department', null,null);
        root3.setAttribute('Department','Physics');
        Dom.XmlNode root4 = root2.addChildElement('Department', null,null);
        root4.setAttribute('Department','Mathematics');
        Dom.XmlNode root5 = root2.addChildElement('Department', null,null);
        root5.setAttribute('Department','Chemistry');
        Dom.XmlNode sub = root3.addChildElement('Subjects', null, null);
        sub.addTextNode('Nuclear Physics');
        sub.addTextNode(' : Statistical Mechanics');
        sub.addTextNode(' : Quantum Mechanics'); // fixed spelling
        Xmldata = doc.toXmlString();
        system.debug(Xmldata);
       // return Xmldata;
    }

   @AuraEnabled(cacheable=true)
public static String getData() {
    recordList();
    if (String.isBlank(Xmldata)) {
        return 'No XML data available. Please call recordList() first.';
    }

    Dom.Document doc = new Dom.Document();
    doc.load(Xmldata);

    Dom.XmlNode root = doc.getRootElement(); // <College>
    List<Dom.XmlNode> deptContainers = root.getChildElements(); // [<Departments>]

    String result = '';

    for (Dom.XmlNode deptContainer : deptContainers) {
        if (deptContainer.getName() == 'Departments') {
            List<Dom.XmlNode> depts = deptContainer.getChildElements(); // <Department> nodes

            for (Dom.XmlNode dept : depts) {
                String deptName = dept.getAttribute('Department', null);
                result += '\nDepartment: ' + deptName;

                List<Dom.XmlNode> children = dept.getChildElements();
                for (Dom.XmlNode child : children) {
                    if (child.getName() == 'Subjects') {
                        result += '\nSubjects: ' + child.getText();
                    }
                }

                result += '\n---';
            }
        }
    }

    System.debug(result);
    return result;
}

}