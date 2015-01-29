package com.xilinx.ultrascale.gui;

import com.sun.org.apache.bcel.internal.generic.AALOAD;
import com.xilinx.ultrascale.jni.DMAStats;
import com.xilinx.ultrascale.jni.DriverInfo;
import com.xilinx.ultrascale.jni.EndPointInfo;
import com.xilinx.ultrascale.jni.EngState;
import com.xilinx.ultrascale.jni.LedStats;
import com.xilinx.ultrascale.jni.PowerStats;
import com.xilinx.ultrascale.jni.TRNStats;
import java.awt.BorderLayout;
import java.awt.CardLayout;
import java.awt.Color;
import java.awt.Dialog;
import java.awt.Dimension;
import java.awt.Point;
import java.awt.event.ComponentAdapter;
import java.awt.event.ComponentEvent;
import java.io.IOException;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.Timer;
import java.util.TimerTask;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.swing.BoxLayout;
import javax.swing.ImageIcon;
import javax.swing.JDialog;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JTable;
import javax.swing.SpinnerNumberModel;
import javax.swing.table.TableModel;
import javax.swing.text.DefaultCaret;
import org.jfree.chart.ChartPanel;
/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author Mobigesture
 */
public class MainScreen extends javax.swing.JFrame {

    LandingPage lp;
    private Timer timer;
    private Timer powerTimer;
    private TableModel tblModel1;
    EndPointInfo epInfo;
    JFrame bdFrame;

    /**
     * Creates new form MainScreen
     */
    private MainScreen() {
        initComponents();
        this.setLocationRelativeTo(null);

        bdFrame = new JFrame("Block Diagram");
        bdFrame.setResizable(false);
        bdFrame.add(blockdiagramlbl);

        ledicons[0] = new ImageIcon(getClass().getResource("/com/xilinx/ultrascale/gui/0.png"));
        ledicons[1] = new ImageIcon(getClass().getResource("/com/xilinx/ultrascale/gui/1.png"));
        ledicons[2] = new ImageIcon(getClass().getResource("/com/xilinx/ultrascale/gui/2.png"));
        ledicons[3] = new ImageIcon(getClass().getResource("/com/xilinx/ultrascale/gui/3.png"));
        ledicons[4] = new ImageIcon(getClass().getResource("/com/xilinx/ultrascale/gui/4.png"));
        ledicons[5] = new ImageIcon(getClass().getResource("/com/xilinx/ultrascale/gui/5.png"));
        ledicons[6] = new ImageIcon(getClass().getResource("/com/xilinx/ultrascale/gui/6.png"));
        ledicons[7] = new ImageIcon(getClass().getResource("/com/xilinx/ultrascale/gui/7.png"));
        ledicons[8] = new ImageIcon(getClass().getResource("/com/xilinx/ultrascale/gui/8.png"));
        ledicons[9] = new ImageIcon(getClass().getResource("/com/xilinx/ultrascale/gui/9.png"));
    }
    int screenMode;
    int ddrledState = -1;

    public void configureScreen(int mode, LandingPage lp) {
        this.lp = lp;
        screenMode = mode;
        testStarted = false;
        if (Develop.production == 1) {
            di = null;
            di = new DriverInfo();
            if (mode == 2) {
                di.init(mode, 1);
            } else if (mode == 4) {
                di.init(mode, 2);
            } else if (mode == 3) {
                di.init(mode, 4);
            } else {
                di.init(mode, 3);
            }
            int ret = di.get_PCIstate();
            ret = di.getBarInfo();

            // fill pcie data
            if (mode != 6) { //ie., not a control plane
                pciemodel = new MyTableModel(di.getPCIInfo().getPCIData(), pcieColumnNames);
                pcieSysmontable.setModel(pciemodel);

                hostCredits = new MyTableModel(di.getPCIInfo().getHostedData(), pcieColumnNames);
                hostsysmontable.setModel(hostCredits);

            } else {
                pciemodel = new MyTableModel(di.getPCIInfo().getPCIDataForCP(), pcieColumnNames);
                pcieSysmontable.setModel(pciemodel);

                hostCredits = new MyTableModel(di.getPCIInfo().getHostedDataForCP(), pcieColumnNames);
                hostsysmontable.setModel(hostCredits);
                // changing the title of the panel of host credits.

            }
            testMode = DriverInfo.CHECKER;
            // initialize max packet size
            //ret = di.get_EngineState();
            //EngState[] engData = di.getEngState();
            epInfo = di.getEndPointInfo();
        }
//            maxSize = engData[0].MaxPktSize;
//            sizeTextField.setText(String.valueOf(maxSize));
        switch (mode) {
            case 0://acc_perf_gen_check
                // No change in heading
                //hide all leds.
                ddricon.setVisible(false);
                DDR4label.setVisible(false);
                phy0icon.setVisible(false);
                phy0label.setVisible(false);
                phy1icon.setVisible(false);
                phty1label.setVisible(false);

                headinglable.setText("AXI-MM Dataplane : Performance Mode (GEN/CHK)");

                // updating block diagram
                blockdiagramlbl.setIcon(new ImageIcon(getClass().getResource("/com/xilinx/ultrascale/gui/BlockDiagram_pcie.jpg")));

                // resize message log.
//                jPanel4.setPreferredSize(new Dimension(jPanel4.getWidth(), 140));
//                jPanel4.setSize(new Dimension(jPanel4.getWidth(), 140));
//                jPanel4.revalidate();
//                jPanel4.repaint();
//                DataPathPanelForOneDP.revalidate();
                break;
            case 1: {//acc_perf_gen_check_ddr
                //hide all leds.
//                jLabel1.setVisible(false);
//                jLabel2.setVisible(false);
                phy0icon.setVisible(false);
                phy0label.setVisible(false);
                phy1icon.setVisible(false);
                phty1label.setVisible(false);
//                tabbedPanel.remove(statusPanel);
                headinglable.setText("AXI-MM Dataplane : Performance Mode (PCIe-DMA-DDR4)");
                blockdiagramlbl.setIcon(new ImageIcon(getClass().getResource("/com/xilinx/ultrascale/gui/BlockDiagram_ddr.jpg")));
                int ret = di.get_LedStats();
                LedStats lstats = di.getLedStats();
                ddrledState = lstats.ddrCalib1;
                if (lstats.ddrCalib1 == 0) {
                    ddricon.setIcon(new ImageIcon(getClass().getResource("/com/xilinx/ultrascale/gui/gray.png")));
                } else {
                    ddricon.setIcon(new ImageIcon(getClass().getResource("/com/xilinx/ultrascale/gui/green.png")));

                }

                // resize message log.
//                jPanel4.setPreferredSize(new Dimension(jPanel4.getWidth(), 130));
//                jPanel4.setSize(new Dimension(jPanel4.getWidth(), 130));
//                jPanel4.revalidate();
//                jPanel4.repaint();
//                DataPathPanelForOneDP.revalidate();
                // renaming hw generator and checker
                CheckerChcekBox.setText("System to Card");
                GeneratorCheckbox.setText("Card to System");
                messageLog.append("AXI-MM Dataplane : Performance Mode (PCIe-DMA-DDR4)\n");
            }
            break;
            case 2: {//acc_application
                //hide all leds.

                phy0icon.setVisible(false);
                phy0label.setVisible(false);
                phy1icon.setVisible(false);
                phty1label.setVisible(false);
                blockdiagramlbl.setIcon(new ImageIcon(getClass().getResource("/com/xilinx/ultrascale/gui/BlockDiagram_video_acc.jpg")));

                int ret = di.get_LedStats();
                LedStats lstats = di.getLedStats();
                ddrledState = lstats.ddrCalib1;

                if (lstats.ddrCalib1 == 0) {
                    ddricon.setIcon(new ImageIcon(getClass().getResource("/com/xilinx/ultrascale/gui/gray.png")));
                } else {
                    ddricon.setIcon(new ImageIcon(getClass().getResource("/com/xilinx/ultrascale/gui/green.png")));

                }
                headinglable.setText("AXI-MM Dataplane : Video Accelerator Mode");
                messageLog2.append("AXI-MM Dataplane : Video Accelerator Mode\n");
                tabbedPanel.remove(statusPanel);
            }
            break;
            case 3://ethernet_perf_raw
                ddricon.setVisible(false);
                DDR4label.setVisible(false);
                jCheckBox2.setEnabled(false);
                jCheckBox3.setEnabled(false);
                jCheckBox5.setEnabled(false);
                jCheckBox6.setEnabled(false);
//                tabbedPanel.remove(sysmonpanel);
//                tabbedPanel.remove(statusPanel);
//                tabbedPanel.setLayout(new CardLayout());
                blockdiagramlbl.setIcon(new ImageIcon(getClass().getResource("/com/xilinx/ultrascale/gui/BlockDiagram_Eth_Raw.png")));
                sizeTextField1.setText("16383");
                sizeTextField2.setText("16383");
                headinglable.setText("AXI Stream Dataplane : Performance mode (Raw Ethernet)");
                break;
            case 7://ethernet_perf_gen_check
                ddricon.setVisible(false);
                DDR4label.setVisible(false);
                phy0icon.setVisible(false);
                phy0label.setVisible(false);
                phy1icon.setVisible(false);
                phty1label.setVisible(false);
                headinglable.setText("AXI Stream Dataplane : Performance mode (GEN-CHK)");
//                tabbedPanel.remove(sysmonpanel);
//                tabbedPanel.setLayout(new CardLayout());
                blockdiagramlbl.setIcon(new ImageIcon(getClass().getResource("/com/xilinx/ultrascale/gui/BlockDiagram_Eth_GC.jpg")));
                messageLog1.append("AXI Stream Dataplane : Performance mode (GEN-CHK)\n");
                break;
            case 4://ethernet_app
                headinglable.setText("AXI Stream Dataplane : Application Mode");
                // disabling the controls.
                ddricon.setVisible(false);
                DDR4label.setVisible(false);
                jCheckBox1.setEnabled(false);
                jCheckBox2.setEnabled(false);
                jCheckBox3.setEnabled(false);
                jCheckBox4.setEnabled(false);
                jCheckBox5.setEnabled(false);
                jCheckBox6.setEnabled(false);
                jButton2.setEnabled(false);
                jButton3.setEnabled(false);
                sizeTextField1.setText("16383");
                sizeTextField2.setText("16383");
//                tabbedPanel.remove(sysmonpanel);
//                tabbedPanel.remove(statusPanel);
//                tabbedPanel.setLayout(new CardLayout());
                blockdiagramlbl.setIcon(new ImageIcon(getClass().getResource("/com/xilinx/ultrascale/gui/BlockDiagram_Eth_AP.jpg")));

                break;
            case 6://control_plane
                // Set combobox values
                barComboBoxTop.removeAllItems();
                barComboBoxTop1.removeAllItems();
                barComboBoxbottom.removeAllItems();
                if (epInfo.designMode == 0) {
                    barComboBoxTop.addItem("Bar2");
                    barComboBoxTop1.addItem("Bar2");
                    barComboBoxbottom.addItem("Bar2");
                } else if (epInfo.designMode == 1) {
                    barComboBoxTop.addItem("Bar4");
                    barComboBoxTop1.addItem("Bar4");
                    barComboBoxbottom.addItem("Bar4");
                } else if (epInfo.designMode == 2) {
                    barComboBoxTop.addItem("Bar2");
                    barComboBoxTop1.addItem("Bar2");
                    barComboBoxbottom.addItem("Bar2");
                    barComboBoxTop.addItem("Bar4");
                    barComboBoxTop1.addItem("Bar4");
                    barComboBoxbottom.addItem("Bar4");
                }
                ddricon.setVisible(false);
                DDR4label.setVisible(false);
                phy0icon.setVisible(false);
                phy0label.setVisible(false);
                phy1icon.setVisible(false);
                phty1label.setVisible(false);
                tabbedPanel.remove(PerformancePlotTab);
                tabbedPanel.remove(statusPanel);
                headinglable.setText("Control Plane");
                this.setSize(this.getSize().width + 40, 610);

                jPanel1.setPreferredSize(new Dimension(279, 600));//
                jPanel1.setSize(279, 600);

                jPanel1.add(PcieEndStatuspanel);
                jPanel1.add(hostCreditsPanel);
                // pcieSysmontable.setPreferredSize(new Dimension(250, 300));
                pcieSysmontable.getColumnModel().getColumn(1).setPreferredWidth(10);
                PcieEndStatuspanel.setSize(jPanel1.getSize().width, jPanel1.getSize().height - 365);
                PcieEndStatuspanel.setLocation(new Point(0, 0));
                hostCreditsPanel.setSize(jPanel1.getSize().width, jPanel1.getSize().height - 340);
                hostCreditsPanel.setLocation(new Point(0, 250));

                ((javax.swing.border.TitledBorder) hostCreditsPanel.getBorder()).setTitle("Endpoint BAR Information");
                jPanel1.repaint();
                jPanel1.revalidate();
//                PcieEndStatuspanel.repaint();
//                 PcieEndStatuspanel.revalidate();
                //TabelModel.getColoum(1).setsize();
                PowerPanel.setPreferredSize(new Dimension(300, 445));
                PowerPanel.revalidate();
                PowerPanel.repaint();
                /*MyTableModel tblModel = new MyTableModel(dummydata, pcieEndptClm);
                 pcieSysmontable.setModel(tblModel);
                 tblModel.setData(dataForPCIEDummy, dmaColumnNames0);
                 tblModel.fireTableDataChanged();*/
                MyTableModel tblModel1 = new MyTableModel(dummydata, hostPcie);
                hostsysmontable.setModel(tblModel1);
                tblModel1.setData(epInfo.getBarStats(), hostPcie);
                tblModel1.fireTableDataChanged();
                MyCellRenderer renderer = new MyCellRenderer();
                barDumpModel = new MyTableModel(bardumpDummy, bardumpNames);
                bardump.setModel(barDumpModel);
                bardump.getColumnModel().getColumn(0).setCellRenderer(renderer);
                bardump.getTableHeader().setReorderingAllowed(false);
                tabbedPanel.setLayout(new CardLayout());

                break;
        }
        alignmentsOfTables();
    }

    private void alignmentsOfTables() {
        //                tblModel = new MyTableModel(dummydata, dmaColumnNames0);
        pcieSysmontable.getTableHeader().setReorderingAllowed(false);
        hostsysmontable.getTableHeader().setReorderingAllowed(false);
        pcieSysmontable.getColumnModel().getColumn(1).setPreferredWidth(5);
        hostsysmontable.setAutoResizeMode(JTable.AUTO_RESIZE_LAST_COLUMN);
        hostsysmontable.getColumnModel().getColumn(1).setMinWidth(10);
        hostsysmontable.getColumnModel().getColumn(1).setMaxWidth(60);

        tabbedPanel.remove(statusPanel);
        this.setSize(this.getSize().width, this.getSize().height - 25);

        // update the message log.
        DefaultCaret caret = (DefaultCaret) messageLog.getCaret();
        caret.setUpdatePolicy(DefaultCaret.ALWAYS_UPDATE);
    }

    /**
     * This method is called from within the constructor to initialize the form.
     * WARNING: DogetColumn NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        VideoPanel = new javax.swing.JPanel();
        topVidpanel = new javax.swing.JPanel();
        pathFied = new javax.swing.JTextField();
        browseButton = new javax.swing.JButton();
        videoplayButton = new javax.swing.JButton();
        videoPauseButton = new javax.swing.JButton();
        mincoeff = new javax.swing.JSpinner();
        maxcoeff = new javax.swing.JSpinner();
        invertcheckbox = new javax.swing.JCheckBox();
        jLabel7 = new javax.swing.JLabel();
        jLabel14 = new javax.swing.JLabel();
        jLabel17 = new javax.swing.JLabel();
        jLabel35 = new javax.swing.JLabel();
        jPanel35 = new javax.swing.JPanel();
        jLabel36 = new javax.swing.JLabel();
        pcieTxTextField4 = new javax.swing.JTextField();
        pcieRxTextField4 = new javax.swing.JTextField();
        jLabel37 = new javax.swing.JLabel();
        jPanel36 = new javax.swing.JPanel();
        jLabel38 = new javax.swing.JLabel();
        axiTxTextField4 = new javax.swing.JTextField();
        axiRxTextField4 = new javax.swing.JTextField();
        jLabel39 = new javax.swing.JLabel();
        messagelogPanel2 = new javax.swing.JPanel();
        jScrollPane8 = new javax.swing.JScrollPane();
        messageLog2 = new javax.swing.JTextArea();
        DataPathPanel = new javax.swing.JPanel();
        jPanel15 = new javax.swing.JPanel();
        jScrollPane4 = new javax.swing.JScrollPane();
        jTable3 = new javax.swing.JTable();
        jLabel8 = new javax.swing.JLabel();
        jCheckBox1 = new javax.swing.JCheckBox();
        jCheckBox2 = new javax.swing.JCheckBox();
        jCheckBox3 = new javax.swing.JCheckBox();
        jLabel9 = new javax.swing.JLabel();
        jTextField1 = new javax.swing.JTextField();
        jButton2 = new javax.swing.JButton();
        jPanel16 = new javax.swing.JPanel();
        jScrollPane5 = new javax.swing.JScrollPane();
        jTable4 = new javax.swing.JTable();
        jLabel10 = new javax.swing.JLabel();
        jCheckBox4 = new javax.swing.JCheckBox();
        jCheckBox5 = new javax.swing.JCheckBox();
        jCheckBox6 = new javax.swing.JCheckBox();
        jLabel11 = new javax.swing.JLabel();
        jTextField2 = new javax.swing.JTextField();
        jButton3 = new javax.swing.JButton();
        jPanel17 = new javax.swing.JPanel();
        jLabel12 = new javax.swing.JLabel();
        jTextField3 = new javax.swing.JTextField();
        jTextField4 = new javax.swing.JTextField();
        jLabel13 = new javax.swing.JLabel();
        ReadWritePanel = new javax.swing.JPanel();
        ReadPanel = new javax.swing.JPanel();
        barComboBoxTop1 = new javax.swing.JComboBox();
        offsetTextField1 = new javax.swing.JTextField();
        dataTextfield1 = new javax.swing.JTextField();
        executeRWButton1 = new javax.swing.JButton();
        jLabel4 = new javax.swing.JLabel();
        jLabel15 = new javax.swing.JLabel();
        WritePanel = new javax.swing.JPanel();
        barComboBoxTop = new javax.swing.JComboBox();
        offsetTextField = new javax.swing.JTextField();
        dataTextfield = new javax.swing.JTextField();
        executeRWButton = new javax.swing.JButton();
        jLabel2 = new javax.swing.JLabel();
        jLabel6 = new javax.swing.JLabel();
        hexdumppanel = new javax.swing.JPanel();
        executeBarButton = new javax.swing.JButton();
        barComboBoxbottom = new javax.swing.JComboBox();
        AddressTextField = new javax.swing.JTextField();
        sizeControlTextField = new javax.swing.JTextField();
        jLabel16 = new javax.swing.JLabel();
        jLabel21 = new javax.swing.JLabel();
        jPanel3 = new javax.swing.JPanel();
        jScrollPane1 = new javax.swing.JScrollPane();
        bardump = new javax.swing.JTable();
        DataPathPanelForOneDP = new javax.swing.JPanel();
        jPanel29 = new javax.swing.JPanel();
        jLabel26 = new javax.swing.JLabel();
        pcieTxTextField1 = new javax.swing.JTextField();
        pcieRxTextField1 = new javax.swing.JTextField();
        jLabel27 = new javax.swing.JLabel();
        jPanel25 = new javax.swing.JPanel();
        CheckerChcekBox = new javax.swing.JCheckBox();
        GeneratorCheckbox = new javax.swing.JCheckBox();
        jLabel18 = new javax.swing.JLabel();
        sizeTextField = new javax.swing.JTextField();
        jbuttonEngStart = new javax.swing.JButton();
        messagelogPanel = new javax.swing.JPanel();
        jScrollPane6 = new javax.swing.JScrollPane();
        messageLog = new javax.swing.JTextArea();
        jPanel27 = new javax.swing.JPanel();
        jLabel22 = new javax.swing.JLabel();
        axiTxTextField = new javax.swing.JTextField();
        axiRxTextField = new javax.swing.JTextField();
        jLabel23 = new javax.swing.JLabel();
        BlockDiagramPanel = new javax.swing.JPanel();
        blockdiagramlbl = new javax.swing.JLabel();
        jPanel28 = new javax.swing.JPanel();
        jLabel24 = new javax.swing.JLabel();
        dmaTxTextField1 = new javax.swing.JTextField();
        dmaRxTextField1 = new javax.swing.JTextField();
        jLabel25 = new javax.swing.JLabel();
        DataPathPanelForOneEC = new javax.swing.JPanel();
        jPanel30 = new javax.swing.JPanel();
        jLabel28 = new javax.swing.JLabel();
        pcieTxTextField2 = new javax.swing.JTextField();
        pcieRxTextField2 = new javax.swing.JTextField();
        jLabel29 = new javax.swing.JLabel();
        jPanel5 = new javax.swing.JPanel();
        jPanel26 = new javax.swing.JPanel();
        CheckerChcekBox1 = new javax.swing.JCheckBox();
        GeneratorCheckbox1 = new javax.swing.JCheckBox();
        jLabel19 = new javax.swing.JLabel();
        sizeTextField1 = new javax.swing.JTextField();
        jbuttonEngStart1 = new javax.swing.JButton();
        loopbackCheckBox1 = new javax.swing.JCheckBox();
        axiTruputpanle0 = new javax.swing.JPanel();
        axilblwrite0 = new javax.swing.JLabel();
        axiTxTextField1 = new javax.swing.JTextField();
        axiRxTextField1 = new javax.swing.JTextField();
        axilblread0 = new javax.swing.JLabel();
        datapathpanel1 = new javax.swing.JPanel();
        jPanel32 = new javax.swing.JPanel();
        CheckerChcekBox2 = new javax.swing.JCheckBox();
        GeneratorCheckbox2 = new javax.swing.JCheckBox();
        jLabel20 = new javax.swing.JLabel();
        sizeTextField2 = new javax.swing.JTextField();
        jbuttonEngStart2 = new javax.swing.JButton();
        loopbackCheckBox2 = new javax.swing.JCheckBox();
        axiTruputpanle1 = new javax.swing.JPanel();
        axilblwrite1 = new javax.swing.JLabel();
        axiTxTextField2 = new javax.swing.JTextField();
        axiRxTextField2 = new javax.swing.JTextField();
        axilblread1 = new javax.swing.JLabel();
        DataPathPanelForOneEC_GC = new javax.swing.JPanel();
        jPanel31 = new javax.swing.JPanel();
        jLabel30 = new javax.swing.JLabel();
        pcieTxTextField3 = new javax.swing.JTextField();
        pcieRxTextField3 = new javax.swing.JTextField();
        jLabel31 = new javax.swing.JLabel();
        jPanel33 = new javax.swing.JPanel();
        CheckerChcekBox3 = new javax.swing.JCheckBox();
        GeneratorCheckbox3 = new javax.swing.JCheckBox();
        jLabel32 = new javax.swing.JLabel();
        sizeTextField3 = new javax.swing.JTextField();
        jbuttonEngStart3 = new javax.swing.JButton();
        messagelogPanel1 = new javax.swing.JPanel();
        jScrollPane7 = new javax.swing.JScrollPane();
        messageLog1 = new javax.swing.JTextArea();
        jPanel34 = new javax.swing.JPanel();
        jLabel33 = new javax.swing.JLabel();
        axiTxTextField3 = new javax.swing.JTextField();
        axiRxTextField3 = new javax.swing.JTextField();
        jLabel34 = new javax.swing.JLabel();
        jPanel4 = new javax.swing.JPanel();
        tempvaluePanel1 = new javax.swing.JPanel();
        TempMeasureLabel1 = new javax.swing.JLabel();
        MinorTempLabel1 = new javax.swing.JLabel();
        MajorTempLabel1 = new javax.swing.JLabel();
        MajorTempLabel2 = new javax.swing.JLabel();
        DyPanel = new javax.swing.JPanel();
        ControlPanel = new javax.swing.JPanel();
        logscrollpanel = new javax.swing.JScrollPane();
        logArea = new javax.swing.JTextArea();
        ledPanel = new javax.swing.JPanel();
        phy0panel = new javax.swing.JPanel();
        phy0icon = new javax.swing.JLabel();
        phy0label = new javax.swing.JLabel();
        phy1panel = new javax.swing.JPanel();
        phy1icon = new javax.swing.JLabel();
        phty1label = new javax.swing.JLabel();
        ddrpanel = new javax.swing.JPanel();
        ddricon = new javax.swing.JLabel();
        DDR4label = new javax.swing.JLabel();
        tabpanel = new javax.swing.JPanel();
        tabbedPanel = new javax.swing.JTabbedPane();
        PerformancePlotTab = new javax.swing.JPanel();
        topChartperfpanel = new javax.swing.JPanel();
        bottomChartperfpanel = new javax.swing.JPanel();
        sysmonpanel = new javax.swing.JPanel();
        tempholdPanel = new javax.swing.JPanel();
        tempvaluePanel = new javax.swing.JPanel();
        TempMeasureLabel = new javax.swing.JLabel();
        MinorTempLabel = new javax.swing.JLabel();
        MajorTempLabel = new javax.swing.JLabel();
        MajorTempLabel3 = new javax.swing.JLabel();
        jLabel1 = new javax.swing.JLabel();
        PowerPanel = new javax.swing.JPanel();
        jPanel1 = new javax.swing.JPanel();
        PcieEndStatuspanel = new javax.swing.JPanel();
        jScrollPane2 = new javax.swing.JScrollPane();
        pcieSysmontable = new javax.swing.JTable();
        hostCreditsPanel = new javax.swing.JPanel();
        jScrollPane3 = new javax.swing.JScrollPane();
        hostsysmontable = new javax.swing.JTable();
        jPanel2 = new javax.swing.JPanel();
        statusPanel = new javax.swing.JPanel();
        HeadingPanel = new javax.swing.JPanel();
        headinglable = new javax.swing.JLabel();
        blockdiagrambutton = new javax.swing.JButton();
        jLabel3 = new javax.swing.JLabel();
        jLabel5 = new javax.swing.JLabel();

        VideoPanel.setPreferredSize(new java.awt.Dimension(364, 404));

        topVidpanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Video Control"));

        browseButton.setText("...");
        browseButton.setToolTipText("Choose Video File");
        browseButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                browseButtonActionPerformed(evt);
            }
        });

        videoplayButton.setText("Start");
        videoplayButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                videoplayButtonActionPerformed(evt);
            }
        });

        videoPauseButton.setText("Pause");
        videoPauseButton.setEnabled(false);
        videoPauseButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                videoPauseButtonActionPerformed(evt);
            }
        });

        mincoeff.setModel(new javax.swing.SpinnerNumberModel(100, 0, 255, 1));
        mincoeff.addChangeListener(new javax.swing.event.ChangeListener() {
            public void stateChanged(javax.swing.event.ChangeEvent evt) {
                mincoeffStateChanged(evt);
            }
        });

        maxcoeff.setModel(new javax.swing.SpinnerNumberModel(200, 0, 255, 1));
        maxcoeff.addChangeListener(new javax.swing.event.ChangeListener() {
            public void stateChanged(javax.swing.event.ChangeEvent evt) {
                maxcoeffStateChanged(evt);
            }
        });

        invertcheckbox.setText("Invert");
        invertcheckbox.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                invertcheckboxActionPerformed(evt);
            }
        });

        jLabel7.setFont(new java.awt.Font("Cantarell", 1, 15)); // NOI18N
        jLabel7.setText("Threshold :");

        jLabel14.setText("Min :");

        jLabel17.setText("Max :");

        jLabel35.setText("Video File Path :");

        javax.swing.GroupLayout topVidpanelLayout = new javax.swing.GroupLayout(topVidpanel);
        topVidpanel.setLayout(topVidpanelLayout);
        topVidpanelLayout.setHorizontalGroup(
            topVidpanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(topVidpanelLayout.createSequentialGroup()
                .addContainerGap()
                .addGroup(topVidpanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(topVidpanelLayout.createSequentialGroup()
                        .addComponent(jLabel7)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(jLabel14, javax.swing.GroupLayout.PREFERRED_SIZE, 40, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(mincoeff, javax.swing.GroupLayout.PREFERRED_SIZE, 56, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                        .addComponent(jLabel17)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(maxcoeff, javax.swing.GroupLayout.PREFERRED_SIZE, 60, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(invertcheckbox, javax.swing.GroupLayout.PREFERRED_SIZE, 67, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(videoPauseButton, javax.swing.GroupLayout.PREFERRED_SIZE, 78, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, topVidpanelLayout.createSequentialGroup()
                        .addComponent(jLabel35, javax.swing.GroupLayout.PREFERRED_SIZE, 107, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(pathFied)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(browseButton, javax.swing.GroupLayout.PREFERRED_SIZE, 30, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(videoplayButton, javax.swing.GroupLayout.PREFERRED_SIZE, 79, javax.swing.GroupLayout.PREFERRED_SIZE)))
                .addContainerGap())
        );
        topVidpanelLayout.setVerticalGroup(
            topVidpanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(topVidpanelLayout.createSequentialGroup()
                .addContainerGap()
                .addGroup(topVidpanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(pathFied, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(jLabel35)
                    .addComponent(browseButton)
                    .addComponent(videoplayButton))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(topVidpanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, topVidpanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                        .addComponent(jLabel14, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                        .addComponent(mincoeff, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(topVidpanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                        .addComponent(maxcoeff, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addComponent(jLabel17, javax.swing.GroupLayout.PREFERRED_SIZE, 22, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addComponent(jLabel7, javax.swing.GroupLayout.PREFERRED_SIZE, 26, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addComponent(videoPauseButton)
                        .addComponent(invertcheckbox)))
                .addContainerGap())
        );

        jPanel35.setBorder(javax.swing.BorderFactory.createTitledBorder("PCIe Throughput"));

        jLabel36.setText("Transmit (Writes in Gbps):");

        pcieTxTextField4.setEditable(false);
        pcieTxTextField4.setText("00.000");

        pcieRxTextField4.setEditable(false);
        pcieRxTextField4.setText("00.000");

        jLabel37.setText("Receive (Reads in Gbps):");

        javax.swing.GroupLayout jPanel35Layout = new javax.swing.GroupLayout(jPanel35);
        jPanel35.setLayout(jPanel35Layout);
        jPanel35Layout.setHorizontalGroup(
            jPanel35Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel35Layout.createSequentialGroup()
                .addGap(6, 6, 6)
                .addComponent(jLabel36)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(pcieTxTextField4, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addComponent(jLabel37)
                .addGap(3, 3, 3)
                .addComponent(pcieRxTextField4, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(4, 4, 4))
        );
        jPanel35Layout.setVerticalGroup(
            jPanel35Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, jPanel35Layout.createSequentialGroup()
                .addContainerGap(25, Short.MAX_VALUE)
                .addGroup(jPanel35Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(jPanel35Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                        .addComponent(jLabel37, javax.swing.GroupLayout.PREFERRED_SIZE, 26, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addComponent(pcieRxTextField4, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(jPanel35Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                        .addComponent(jLabel36, javax.swing.GroupLayout.PREFERRED_SIZE, 26, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addComponent(pcieTxTextField4, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)))
                .addContainerGap())
        );

        jPanel36.setBorder(javax.swing.BorderFactory.createTitledBorder("DDR Throughput"));

        jLabel38.setText("DDR-Writes (in Gbps):");
        jLabel38.setToolTipText("");

        axiTxTextField4.setEditable(false);
        axiTxTextField4.setText("00.000");

        axiRxTextField4.setEditable(false);
        axiRxTextField4.setText("00.000");

        jLabel39.setText("DDR-Reads (in Gbps):");
        jLabel39.setToolTipText("");

        javax.swing.GroupLayout jPanel36Layout = new javax.swing.GroupLayout(jPanel36);
        jPanel36.setLayout(jPanel36Layout);
        jPanel36Layout.setHorizontalGroup(
            jPanel36Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel36Layout.createSequentialGroup()
                .addGap(6, 6, 6)
                .addComponent(jLabel38, javax.swing.GroupLayout.PREFERRED_SIZE, 161, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(axiTxTextField4, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addComponent(jLabel39, javax.swing.GroupLayout.PREFERRED_SIZE, 156, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(axiRxTextField4, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(4, 4, 4))
        );
        jPanel36Layout.setVerticalGroup(
            jPanel36Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, jPanel36Layout.createSequentialGroup()
                .addContainerGap(22, Short.MAX_VALUE)
                .addGroup(jPanel36Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                    .addComponent(jLabel38, javax.swing.GroupLayout.PREFERRED_SIZE, 26, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addGroup(jPanel36Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                        .addComponent(jLabel39, javax.swing.GroupLayout.PREFERRED_SIZE, 26, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addComponent(axiRxTextField4, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addComponent(axiTxTextField4, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)))
                .addContainerGap())
        );

        messagelogPanel2.setBorder(javax.swing.BorderFactory.createTitledBorder("Message log"));
        messagelogPanel2.setPreferredSize(new java.awt.Dimension(294, 139));

        jScrollPane8.setHorizontalScrollBarPolicy(javax.swing.ScrollPaneConstants.HORIZONTAL_SCROLLBAR_NEVER);

        messageLog2.setEditable(false);
        messageLog2.setColumns(20);
        messageLog2.setRows(5);
        jScrollPane8.setViewportView(messageLog2);

        javax.swing.GroupLayout messagelogPanel2Layout = new javax.swing.GroupLayout(messagelogPanel2);
        messagelogPanel2.setLayout(messagelogPanel2Layout);
        messagelogPanel2Layout.setHorizontalGroup(
            messagelogPanel2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jScrollPane8)
        );
        messagelogPanel2Layout.setVerticalGroup(
            messagelogPanel2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jScrollPane8, javax.swing.GroupLayout.DEFAULT_SIZE, 171, Short.MAX_VALUE)
        );

        javax.swing.GroupLayout VideoPanelLayout = new javax.swing.GroupLayout(VideoPanel);
        VideoPanel.setLayout(VideoPanelLayout);
        VideoPanelLayout.setHorizontalGroup(
            VideoPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(VideoPanelLayout.createSequentialGroup()
                .addContainerGap()
                .addGroup(VideoPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(topVidpanel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(jPanel35, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(jPanel36, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(messagelogPanel2, javax.swing.GroupLayout.DEFAULT_SIZE, 504, Short.MAX_VALUE))
                .addContainerGap())
        );
        VideoPanelLayout.setVerticalGroup(
            VideoPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(VideoPanelLayout.createSequentialGroup()
                .addContainerGap()
                .addComponent(topVidpanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jPanel35, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jPanel36, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(messagelogPanel2, javax.swing.GroupLayout.PREFERRED_SIZE, 199, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        DataPathPanel.setPreferredSize(new java.awt.Dimension(364, 404));

        jPanel15.setBorder(javax.swing.BorderFactory.createEtchedBorder());

        jTable3.setModel(new javax.swing.table.DefaultTableModel(
            new Object [][] {
                {"Troughput(Gbps)", "0.000", "0.000"},
                {"BD Errors", "0", "0"},
                {"SW BDs", "1999", "1999"}
            },
            new String [] {
                "Parameters", "Transmit(S2C0)", "Receive(S2C0)"
            }
        ) {
            boolean[] canEdit = new boolean [] {
                false, false, false
            };

            public boolean isCellEditable(int rowIndex, int columnIndex) {
                return canEdit [columnIndex];
            }
        });
        jScrollPane4.setViewportView(jTable3);

        jLabel8.setText("Data Path-1:");

        jCheckBox1.setText("Loopback");
        jCheckBox1.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jCheckBox1ActionPerformed(evt);
            }
        });

        jCheckBox2.setText("HW Checker");
        jCheckBox2.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jCheckBox2ActionPerformed(evt);
            }
        });

        jCheckBox3.setText("HW Generator");

        jLabel9.setText("Packet Size (bytes):");

        jTextField1.setText("32768");

        jButton2.setText("Start");

        javax.swing.GroupLayout jPanel15Layout = new javax.swing.GroupLayout(jPanel15);
        jPanel15.setLayout(jPanel15Layout);
        jPanel15Layout.setHorizontalGroup(
            jPanel15Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel15Layout.createSequentialGroup()
                .addContainerGap()
                .addGroup(jPanel15Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(jPanel15Layout.createSequentialGroup()
                        .addComponent(jLabel8)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addGroup(jPanel15Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(jCheckBox1)
                            .addComponent(jCheckBox3)
                            .addGroup(jPanel15Layout.createSequentialGroup()
                                .addComponent(jCheckBox2)
                                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                                .addComponent(jLabel9)
                                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                                .addComponent(jTextField1, javax.swing.GroupLayout.PREFERRED_SIZE, 45, javax.swing.GroupLayout.PREFERRED_SIZE)
                                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                                .addComponent(jButton2)))
                        .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
                    .addGroup(jPanel15Layout.createSequentialGroup()
                        .addComponent(jScrollPane4, javax.swing.GroupLayout.PREFERRED_SIZE, 0, Short.MAX_VALUE)
                        .addGap(1, 1, 1))))
        );
        jPanel15Layout.setVerticalGroup(
            jPanel15Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, jPanel15Layout.createSequentialGroup()
                .addContainerGap()
                .addComponent(jCheckBox1, javax.swing.GroupLayout.PREFERRED_SIZE, 16, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(jPanel15Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jCheckBox2, javax.swing.GroupLayout.PREFERRED_SIZE, 14, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(jLabel8)
                    .addComponent(jLabel9)
                    .addComponent(jTextField1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(jButton2))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addComponent(jCheckBox3, javax.swing.GroupLayout.PREFERRED_SIZE, 18, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(jScrollPane4, javax.swing.GroupLayout.PREFERRED_SIZE, 80, javax.swing.GroupLayout.PREFERRED_SIZE))
        );

        jPanel16.setBorder(javax.swing.BorderFactory.createEtchedBorder());

        jTable4.setModel(new javax.swing.table.DefaultTableModel(
            new Object [][] {
                {"Troughput(Gbps)", "0.000", "0.000"},
                {"BD Errors", "0", "0"},
                {"SW BDs", "1999", "1999"}
            },
            new String [] {
                "Parameters", "Transmit(S2C0)", "Receive(S2C0)"
            }
        ) {
            boolean[] canEdit = new boolean [] {
                false, false, false
            };

            public boolean isCellEditable(int rowIndex, int columnIndex) {
                return canEdit [columnIndex];
            }
        });
        jScrollPane5.setViewportView(jTable4);

        jLabel10.setText("Data Path-0:");

        jCheckBox4.setText("Loopback");
        jCheckBox4.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jCheckBox4ActionPerformed(evt);
            }
        });

        jCheckBox5.setText("HW Checker");
        jCheckBox5.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jCheckBox5ActionPerformed(evt);
            }
        });

        jCheckBox6.setText("HW Generator");

        jLabel11.setText("Packet Size (bytes):");

        jTextField2.setText("32768");

        jButton3.setText("Start");

        javax.swing.GroupLayout jPanel16Layout = new javax.swing.GroupLayout(jPanel16);
        jPanel16.setLayout(jPanel16Layout);
        jPanel16Layout.setHorizontalGroup(
            jPanel16Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel16Layout.createSequentialGroup()
                .addContainerGap()
                .addGroup(jPanel16Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(jPanel16Layout.createSequentialGroup()
                        .addComponent(jLabel10)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addGroup(jPanel16Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(jCheckBox4)
                            .addComponent(jCheckBox6)
                            .addGroup(jPanel16Layout.createSequentialGroup()
                                .addComponent(jCheckBox5)
                                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                                .addComponent(jLabel11)
                                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                                .addComponent(jTextField2, javax.swing.GroupLayout.PREFERRED_SIZE, 45, javax.swing.GroupLayout.PREFERRED_SIZE)
                                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                                .addComponent(jButton3)))
                        .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
                    .addGroup(jPanel16Layout.createSequentialGroup()
                        .addComponent(jScrollPane5, javax.swing.GroupLayout.PREFERRED_SIZE, 0, Short.MAX_VALUE)
                        .addGap(1, 1, 1))))
        );
        jPanel16Layout.setVerticalGroup(
            jPanel16Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, jPanel16Layout.createSequentialGroup()
                .addContainerGap()
                .addComponent(jCheckBox4, javax.swing.GroupLayout.PREFERRED_SIZE, 16, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(jPanel16Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jCheckBox5, javax.swing.GroupLayout.PREFERRED_SIZE, 14, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(jLabel10)
                    .addComponent(jLabel11)
                    .addComponent(jTextField2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(jButton3))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addComponent(jCheckBox6, javax.swing.GroupLayout.PREFERRED_SIZE, 18, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(jScrollPane5, javax.swing.GroupLayout.PREFERRED_SIZE, 80, javax.swing.GroupLayout.PREFERRED_SIZE))
        );

        jPanel17.setBorder(javax.swing.BorderFactory.createTitledBorder("PCIe Status"));

        jLabel12.setText("Transmit (writes in Gbps):");

        jTextField3.setText("0.000");

        jTextField4.setText("0.000");

        jLabel13.setText("Receive (reads in Gbps):");

        javax.swing.GroupLayout jPanel17Layout = new javax.swing.GroupLayout(jPanel17);
        jPanel17.setLayout(jPanel17Layout);
        jPanel17Layout.setHorizontalGroup(
            jPanel17Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel17Layout.createSequentialGroup()
                .addContainerGap()
                .addComponent(jLabel12)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jTextField3, javax.swing.GroupLayout.PREFERRED_SIZE, 42, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addComponent(jLabel13)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jTextField4, javax.swing.GroupLayout.PREFERRED_SIZE, 43, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap())
        );
        jPanel17Layout.setVerticalGroup(
            jPanel17Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, jPanel17Layout.createSequentialGroup()
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addGroup(jPanel17Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(jPanel17Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                        .addComponent(jLabel13)
                        .addComponent(jTextField4, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(jPanel17Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                        .addComponent(jLabel12)
                        .addComponent(jTextField3, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)))
                .addContainerGap())
        );

        javax.swing.GroupLayout DataPathPanelLayout = new javax.swing.GroupLayout(DataPathPanel);
        DataPathPanel.setLayout(DataPathPanelLayout);
        DataPathPanelLayout.setHorizontalGroup(
            DataPathPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(DataPathPanelLayout.createSequentialGroup()
                .addGap(0, 0, 0)
                .addGroup(DataPathPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(jPanel16, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(jPanel15, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(jPanel17, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)))
        );
        DataPathPanelLayout.setVerticalGroup(
            DataPathPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, DataPathPanelLayout.createSequentialGroup()
                .addContainerGap()
                .addComponent(jPanel16, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jPanel17, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jPanel15, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        ReadWritePanel.setPreferredSize(new java.awt.Dimension(364, 404));

        ReadPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Read"));

        barComboBoxTop1.setModel(new javax.swing.DefaultComboBoxModel(new String[] { "BAR 2", "BAR 4" }));

        offsetTextField1.setText("0x");
        offsetTextField1.setToolTipText("Offset Range 0x0 - 0x0FFF");

        dataTextfield1.setEditable(false);

        executeRWButton1.setText("Read");
        executeRWButton1.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                executeRWButton1ActionPerformed(evt);
            }
        });

        jLabel4.setText("Data:");

        jLabel15.setText("Offset:");

        javax.swing.GroupLayout ReadPanelLayout = new javax.swing.GroupLayout(ReadPanel);
        ReadPanel.setLayout(ReadPanelLayout);
        ReadPanelLayout.setHorizontalGroup(
            ReadPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(ReadPanelLayout.createSequentialGroup()
                .addContainerGap()
                .addComponent(barComboBoxTop1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jLabel15)
                .addGap(6, 6, 6)
                .addComponent(offsetTextField1, javax.swing.GroupLayout.PREFERRED_SIZE, 93, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(24, 24, 24)
                .addComponent(jLabel4)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(dataTextfield1, javax.swing.GroupLayout.PREFERRED_SIZE, 102, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(executeRWButton1, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addContainerGap())
        );
        ReadPanelLayout.setVerticalGroup(
            ReadPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(ReadPanelLayout.createSequentialGroup()
                .addGap(5, 5, 5)
                .addGroup(ReadPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(barComboBoxTop1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(offsetTextField1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(dataTextfield1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(executeRWButton1)
                    .addComponent(jLabel4)
                    .addComponent(jLabel15))
                .addGap(5, 5, 5))
        );

        WritePanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Write"));

        barComboBoxTop.setModel(new javax.swing.DefaultComboBoxModel(new String[] { "BAR 2", "BAR 4" }));

        offsetTextField.setText("0x");
        offsetTextField.setToolTipText("Offset Range: 0x0 - 0x0FFF");

        dataTextfield.setText("0x");
        dataTextfield.setToolTipText("");

        executeRWButton.setText("Write");
        executeRWButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                executeRWButtonActionPerformed(evt);
            }
        });

        jLabel2.setText("Data:");

        jLabel6.setText("Offset:");

        javax.swing.GroupLayout WritePanelLayout = new javax.swing.GroupLayout(WritePanel);
        WritePanel.setLayout(WritePanelLayout);
        WritePanelLayout.setHorizontalGroup(
            WritePanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(WritePanelLayout.createSequentialGroup()
                .addContainerGap()
                .addComponent(barComboBoxTop, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jLabel6)
                .addGap(5, 5, 5)
                .addComponent(offsetTextField, javax.swing.GroupLayout.PREFERRED_SIZE, 93, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(24, 24, 24)
                .addComponent(jLabel2)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(dataTextfield, javax.swing.GroupLayout.PREFERRED_SIZE, 102, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(executeRWButton, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addContainerGap())
        );
        WritePanelLayout.setVerticalGroup(
            WritePanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(WritePanelLayout.createSequentialGroup()
                .addGap(5, 5, 5)
                .addGroup(WritePanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(barComboBoxTop, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(offsetTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(dataTextfield, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(executeRWButton)
                    .addComponent(jLabel2)
                    .addComponent(jLabel6))
                .addGap(5, 5, 5))
        );

        hexdumppanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Hex Dump"));

        executeBarButton.setText("Dump");
        executeBarButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                executeBarButtonActionPerformed(evt);
            }
        });

        barComboBoxbottom.setModel(new javax.swing.DefaultComboBoxModel(new String[] { "BAR 2", "BAR 4" }));
        barComboBoxbottom.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                barComboBoxbottomActionPerformed(evt);
            }
        });

        AddressTextField.setText("0x");
        AddressTextField.setToolTipText("Offset Range 0x0 - 0x0FFF");

        sizeControlTextField.setToolTipText("Size in bytes (decimal)");
        sizeControlTextField.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                sizeControlTextFieldActionPerformed(evt);
            }
        });

        jLabel16.setText("Offset:");

        jLabel21.setText("Size:");

        jScrollPane1.setMaximumSize(new java.awt.Dimension(452, 402));

        bardump.setModel(new javax.swing.table.DefaultTableModel(
            new Object [][] {
                {null, null, null, null, null},
                {null, null, null, null, null},
                {null, null, null, null, null},
                {null, null, null, null, null},
                {null, null, null, null, null},
                {null, null, null, null, null},
                {null, null, null, null, null},
                {null, null, null, null, null},
                {null, null, null, null, null},
                {null, null, null, null, null},
                {null, null, null, null, null},
                {null, null, null, null, null},
                {null, null, null, null, null},
                {null, null, null, null, null}
            },
            new String [] {
                "Title 1", "Title 2", "Title 3", "Title 4", "Title 5"
            }
        ));
        bardump.setMaximumSize(new java.awt.Dimension(375, 360));
        jScrollPane1.setViewportView(bardump);

        javax.swing.GroupLayout jPanel3Layout = new javax.swing.GroupLayout(jPanel3);
        jPanel3.setLayout(jPanel3Layout);
        jPanel3Layout.setHorizontalGroup(
            jPanel3Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jScrollPane1, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
        );
        jPanel3Layout.setVerticalGroup(
            jPanel3Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jScrollPane1, javax.swing.GroupLayout.DEFAULT_SIZE, 121, Short.MAX_VALUE)
        );

        javax.swing.GroupLayout hexdumppanelLayout = new javax.swing.GroupLayout(hexdumppanel);
        hexdumppanel.setLayout(hexdumppanelLayout);
        hexdumppanelLayout.setHorizontalGroup(
            hexdumppanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(hexdumppanelLayout.createSequentialGroup()
                .addGap(7, 7, 7)
                .addGroup(hexdumppanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(jPanel3, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addGroup(hexdumppanelLayout.createSequentialGroup()
                        .addComponent(barComboBoxbottom, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(jLabel16)
                        .addGap(4, 4, 4)
                        .addComponent(AddressTextField, javax.swing.GroupLayout.PREFERRED_SIZE, 91, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(26, 26, 26)
                        .addComponent(jLabel21, javax.swing.GroupLayout.PREFERRED_SIZE, 29, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(sizeControlTextField, javax.swing.GroupLayout.PREFERRED_SIZE, 101, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(executeBarButton, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)))
                .addContainerGap())
        );
        hexdumppanelLayout.setVerticalGroup(
            hexdumppanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(hexdumppanelLayout.createSequentialGroup()
                .addGroup(hexdumppanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(barComboBoxbottom, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(AddressTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(sizeControlTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(executeBarButton)
                    .addComponent(jLabel16)
                    .addComponent(jLabel21))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jPanel3, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addContainerGap())
        );

        javax.swing.GroupLayout ReadWritePanelLayout = new javax.swing.GroupLayout(ReadWritePanel);
        ReadWritePanel.setLayout(ReadWritePanelLayout);
        ReadWritePanelLayout.setHorizontalGroup(
            ReadWritePanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(ReadWritePanelLayout.createSequentialGroup()
                .addContainerGap()
                .addGroup(ReadWritePanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(hexdumppanel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(WritePanel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(ReadPanel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)))
        );
        ReadWritePanelLayout.setVerticalGroup(
            ReadWritePanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(ReadWritePanelLayout.createSequentialGroup()
                .addContainerGap()
                .addComponent(ReadPanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(9, 9, 9)
                .addComponent(WritePanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(10, 10, 10)
                .addComponent(hexdumppanel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addGap(40, 40, 40))
        );

        DataPathPanelForOneDP.setPreferredSize(new java.awt.Dimension(364, 404));

        jPanel29.setBorder(javax.swing.BorderFactory.createTitledBorder("PCIe Throughput"));

        jLabel26.setText("Transmit (Writes in Gbps):");

        pcieTxTextField1.setEditable(false);
        pcieTxTextField1.setText("00.000");

        pcieRxTextField1.setEditable(false);
        pcieRxTextField1.setText("00.000");

        jLabel27.setText("Receive (Reads in Gbps):");

        javax.swing.GroupLayout jPanel29Layout = new javax.swing.GroupLayout(jPanel29);
        jPanel29.setLayout(jPanel29Layout);
        jPanel29Layout.setHorizontalGroup(
            jPanel29Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel29Layout.createSequentialGroup()
                .addGap(6, 6, 6)
                .addComponent(jLabel26)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(pcieTxTextField1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addComponent(jLabel27)
                .addGap(3, 3, 3)
                .addComponent(pcieRxTextField1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(4, 4, 4))
        );
        jPanel29Layout.setVerticalGroup(
            jPanel29Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, jPanel29Layout.createSequentialGroup()
                .addContainerGap(23, Short.MAX_VALUE)
                .addGroup(jPanel29Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(jPanel29Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                        .addComponent(jLabel27, javax.swing.GroupLayout.PREFERRED_SIZE, 26, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addComponent(pcieRxTextField1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(jPanel29Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                        .addComponent(jLabel26, javax.swing.GroupLayout.PREFERRED_SIZE, 26, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addComponent(pcieTxTextField1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)))
                .addContainerGap())
        );

        jPanel25.setBorder(javax.swing.BorderFactory.createTitledBorder("Test Control"));

        CheckerChcekBox.setSelected(true);
        CheckerChcekBox.setText("System to Card");
        CheckerChcekBox.setToolTipText("Traffic from host memory to endpoint card");
        CheckerChcekBox.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                CheckerChcekBoxActionPerformed(evt);
            }
        });

        GeneratorCheckbox.setText("Card to System");
        GeneratorCheckbox.setToolTipText("Traffic from endpoint card to host memory");
        GeneratorCheckbox.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                GeneratorCheckboxActionPerformed(evt);
            }
        });

        jLabel18.setText("Packet Size (Bytes):");

        sizeTextField.setText("32768");
        sizeTextField.setToolTipText("64 to 32768");
        sizeTextField.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                sizeTextFieldActionPerformed(evt);
            }
        });

        jbuttonEngStart.setText("Start");
        jbuttonEngStart.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jbuttonEngStartActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout jPanel25Layout = new javax.swing.GroupLayout(jPanel25);
        jPanel25.setLayout(jPanel25Layout);
        jPanel25Layout.setHorizontalGroup(
            jPanel25Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel25Layout.createSequentialGroup()
                .addGap(45, 45, 45)
                .addGroup(jPanel25Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(jPanel25Layout.createSequentialGroup()
                        .addComponent(CheckerChcekBox)
                        .addGap(31, 31, 31)
                        .addComponent(jLabel18)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(sizeTextField, javax.swing.GroupLayout.PREFERRED_SIZE, 82, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addComponent(GeneratorCheckbox))
                .addGap(18, 18, 18)
                .addComponent(jbuttonEngStart, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addContainerGap())
        );
        jPanel25Layout.setVerticalGroup(
            jPanel25Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel25Layout.createSequentialGroup()
                .addGroup(jPanel25Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(jPanel25Layout.createSequentialGroup()
                        .addGap(5, 5, 5)
                        .addComponent(CheckerChcekBox, javax.swing.GroupLayout.PREFERRED_SIZE, 14, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(GeneratorCheckbox, javax.swing.GroupLayout.PREFERRED_SIZE, 18, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(jPanel25Layout.createSequentialGroup()
                        .addContainerGap()
                        .addGroup(jPanel25Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(sizeTextField, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addGroup(jPanel25Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                                .addComponent(jLabel18)
                                .addComponent(jbuttonEngStart)))))
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        messagelogPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Message log"));
        messagelogPanel.setPreferredSize(new java.awt.Dimension(294, 139));

        jScrollPane6.setHorizontalScrollBarPolicy(javax.swing.ScrollPaneConstants.HORIZONTAL_SCROLLBAR_NEVER);

        messageLog.setEditable(false);
        messageLog.setColumns(20);
        messageLog.setRows(5);
        jScrollPane6.setViewportView(messageLog);

        javax.swing.GroupLayout messagelogPanelLayout = new javax.swing.GroupLayout(messagelogPanel);
        messagelogPanel.setLayout(messagelogPanelLayout);
        messagelogPanelLayout.setHorizontalGroup(
            messagelogPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jScrollPane6)
        );
        messagelogPanelLayout.setVerticalGroup(
            messagelogPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jScrollPane6, javax.swing.GroupLayout.DEFAULT_SIZE, 205, Short.MAX_VALUE)
        );

        jPanel27.setBorder(javax.swing.BorderFactory.createTitledBorder("DDR Throughput"));

        jLabel22.setText("DDR-Writes (in Gbps):");
        jLabel22.setToolTipText("");

        axiTxTextField.setEditable(false);
        axiTxTextField.setText("00.000");

        axiRxTextField.setEditable(false);
        axiRxTextField.setText("00.000");

        jLabel23.setText("DDR-Reads (in Gbps):");
        jLabel23.setToolTipText("");

        javax.swing.GroupLayout jPanel27Layout = new javax.swing.GroupLayout(jPanel27);
        jPanel27.setLayout(jPanel27Layout);
        jPanel27Layout.setHorizontalGroup(
            jPanel27Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel27Layout.createSequentialGroup()
                .addGap(6, 6, 6)
                .addComponent(jLabel22, javax.swing.GroupLayout.PREFERRED_SIZE, 161, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(axiTxTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addComponent(jLabel23, javax.swing.GroupLayout.PREFERRED_SIZE, 156, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(axiRxTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(4, 4, 4))
        );
        jPanel27Layout.setVerticalGroup(
            jPanel27Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, jPanel27Layout.createSequentialGroup()
                .addContainerGap(20, Short.MAX_VALUE)
                .addGroup(jPanel27Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                    .addComponent(jLabel22, javax.swing.GroupLayout.PREFERRED_SIZE, 26, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addGroup(jPanel27Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                        .addComponent(jLabel23, javax.swing.GroupLayout.PREFERRED_SIZE, 26, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addComponent(axiRxTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addComponent(axiTxTextField, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)))
                .addContainerGap())
        );

        javax.swing.GroupLayout DataPathPanelForOneDPLayout = new javax.swing.GroupLayout(DataPathPanelForOneDP);
        DataPathPanelForOneDP.setLayout(DataPathPanelForOneDPLayout);
        DataPathPanelForOneDPLayout.setHorizontalGroup(
            DataPathPanelForOneDPLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(DataPathPanelForOneDPLayout.createSequentialGroup()
                .addContainerGap()
                .addGroup(DataPathPanelForOneDPLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(messagelogPanel, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.DEFAULT_SIZE, 520, Short.MAX_VALUE)
                    .addComponent(jPanel25, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(jPanel29, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(jPanel27, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)))
        );
        DataPathPanelForOneDPLayout.setVerticalGroup(
            DataPathPanelForOneDPLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, DataPathPanelForOneDPLayout.createSequentialGroup()
                .addGap(11, 11, 11)
                .addComponent(jPanel25, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jPanel29, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jPanel27, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(messagelogPanel, javax.swing.GroupLayout.PREFERRED_SIZE, 227, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        blockdiagramlbl.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
        blockdiagramlbl.setIcon(new javax.swing.ImageIcon(getClass().getResource("/com/xilinx/ultrascale/gui/BlockDiagram.png"))); // NOI18N

        javax.swing.GroupLayout BlockDiagramPanelLayout = new javax.swing.GroupLayout(BlockDiagramPanel);
        BlockDiagramPanel.setLayout(BlockDiagramPanelLayout);
        BlockDiagramPanelLayout.setHorizontalGroup(
            BlockDiagramPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(blockdiagramlbl, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
        );
        BlockDiagramPanelLayout.setVerticalGroup(
            BlockDiagramPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(blockdiagramlbl, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
        );

        jPanel28.setBorder(javax.swing.BorderFactory.createTitledBorder("PCIe Statistics"));

        jLabel24.setText("Transmit (Writes in Gbps):");

        dmaTxTextField1.setEditable(false);
        dmaTxTextField1.setText("00.000");

        dmaRxTextField1.setEditable(false);
        dmaRxTextField1.setText("00.000");

        jLabel25.setText("Receive (Reads in Gbps):");

        javax.swing.GroupLayout jPanel28Layout = new javax.swing.GroupLayout(jPanel28);
        jPanel28.setLayout(jPanel28Layout);
        jPanel28Layout.setHorizontalGroup(
            jPanel28Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel28Layout.createSequentialGroup()
                .addGap(6, 6, 6)
                .addComponent(jLabel24)
                .addGap(1, 1, 1)
                .addComponent(dmaTxTextField1, javax.swing.GroupLayout.PREFERRED_SIZE, 59, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addComponent(jLabel25)
                .addGap(3, 3, 3)
                .addComponent(dmaRxTextField1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(4, 4, 4))
        );
        jPanel28Layout.setVerticalGroup(
            jPanel28Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, jPanel28Layout.createSequentialGroup()
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addGroup(jPanel28Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(jPanel28Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                        .addComponent(jLabel25)
                        .addComponent(dmaRxTextField1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(jPanel28Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                        .addComponent(jLabel24)
                        .addComponent(dmaTxTextField1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)))
                .addContainerGap())
        );

        DataPathPanelForOneEC.setPreferredSize(new java.awt.Dimension(364, 404));

        jPanel30.setBorder(javax.swing.BorderFactory.createTitledBorder("PCIe Throughput"));

        jLabel28.setText("Transmit (Writes in Gbps):");

        pcieTxTextField2.setEditable(false);
        pcieTxTextField2.setText("00.000");

        pcieRxTextField2.setEditable(false);
        pcieRxTextField2.setText("00.000");

        jLabel29.setText("Receive (Reads in Gbps):");

        javax.swing.GroupLayout jPanel30Layout = new javax.swing.GroupLayout(jPanel30);
        jPanel30.setLayout(jPanel30Layout);
        jPanel30Layout.setHorizontalGroup(
            jPanel30Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel30Layout.createSequentialGroup()
                .addGap(6, 6, 6)
                .addComponent(jLabel28)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(pcieTxTextField2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addComponent(jLabel29)
                .addGap(3, 3, 3)
                .addComponent(pcieRxTextField2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(4, 4, 4))
        );
        jPanel30Layout.setVerticalGroup(
            jPanel30Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, jPanel30Layout.createSequentialGroup()
                .addContainerGap(21, Short.MAX_VALUE)
                .addGroup(jPanel30Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(jPanel30Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                        .addComponent(jLabel29, javax.swing.GroupLayout.PREFERRED_SIZE, 26, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addComponent(pcieRxTextField2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(jPanel30Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                        .addComponent(jLabel28, javax.swing.GroupLayout.PREFERRED_SIZE, 26, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addComponent(pcieTxTextField2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)))
                .addContainerGap())
        );

        jPanel5.setBorder(javax.swing.BorderFactory.createEtchedBorder());

        jPanel26.setBorder(javax.swing.BorderFactory.createTitledBorder("Data Path 0"));

        CheckerChcekBox1.setSelected(true);
        CheckerChcekBox1.setText("HW Checker");
        CheckerChcekBox1.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                CheckerChcekBox1ActionPerformed(evt);
            }
        });

        GeneratorCheckbox1.setText("HW Generator");
        GeneratorCheckbox1.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                GeneratorCheckbox1ActionPerformed(evt);
            }
        });

        jLabel19.setText("Packet Size (Bytes):");
        jLabel19.setVerticalAlignment(javax.swing.SwingConstants.TOP);

        sizeTextField1.setText("32768");
        sizeTextField1.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                sizeTextField1ActionPerformed(evt);
            }
        });

        jbuttonEngStart1.setText("Start");
        jbuttonEngStart1.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jbuttonEngStart1ActionPerformed(evt);
            }
        });

        loopbackCheckBox1.setText("Loopback");
        loopbackCheckBox1.setEnabled(false);

        javax.swing.GroupLayout jPanel26Layout = new javax.swing.GroupLayout(jPanel26);
        jPanel26.setLayout(jPanel26Layout);
        jPanel26Layout.setHorizontalGroup(
            jPanel26Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel26Layout.createSequentialGroup()
                .addGap(44, 44, 44)
                .addGroup(jPanel26Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(GeneratorCheckbox1)
                    .addGroup(jPanel26Layout.createSequentialGroup()
                        .addGroup(jPanel26Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(CheckerChcekBox1)
                            .addComponent(loopbackCheckBox1))
                        .addGap(32, 32, 32)
                        .addComponent(jLabel19)))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(sizeTextField1, javax.swing.GroupLayout.PREFERRED_SIZE, 82, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(18, 18, 18)
                .addComponent(jbuttonEngStart1)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );
        jPanel26Layout.setVerticalGroup(
            jPanel26Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel26Layout.createSequentialGroup()
                .addGroup(jPanel26Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(jPanel26Layout.createSequentialGroup()
                        .addGap(13, 13, 13)
                        .addGroup(jPanel26Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                            .addComponent(sizeTextField1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(jbuttonEngStart1)))
                    .addGroup(jPanel26Layout.createSequentialGroup()
                        .addComponent(loopbackCheckBox1)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(CheckerChcekBox1, javax.swing.GroupLayout.PREFERRED_SIZE, 14, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addComponent(jLabel19, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.PREFERRED_SIZE, 24, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(GeneratorCheckbox1, javax.swing.GroupLayout.PREFERRED_SIZE, 18, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(6, 6, 6))
        );

        axiTruputpanle0.setBorder(javax.swing.BorderFactory.createTitledBorder("AXI Throughput"));

        axilblwrite0.setText("AXI-Writes (in Gbps):");
        axilblwrite0.setToolTipText("");

        axiTxTextField1.setEditable(false);
        axiTxTextField1.setText("00.000");

        axiRxTextField1.setEditable(false);
        axiRxTextField1.setText("00.000");

        axilblread0.setText("AXI-Reads (in Gbps):");
        axilblread0.setToolTipText("");

        javax.swing.GroupLayout axiTruputpanle0Layout = new javax.swing.GroupLayout(axiTruputpanle0);
        axiTruputpanle0.setLayout(axiTruputpanle0Layout);
        axiTruputpanle0Layout.setHorizontalGroup(
            axiTruputpanle0Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(axiTruputpanle0Layout.createSequentialGroup()
                .addGap(6, 6, 6)
                .addComponent(axilblwrite0, javax.swing.GroupLayout.PREFERRED_SIZE, 161, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(axiTxTextField1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addComponent(axilblread0, javax.swing.GroupLayout.PREFERRED_SIZE, 156, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(axiRxTextField1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(4, 4, 4))
        );
        axiTruputpanle0Layout.setVerticalGroup(
            axiTruputpanle0Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, axiTruputpanle0Layout.createSequentialGroup()
                .addContainerGap(13, Short.MAX_VALUE)
                .addGroup(axiTruputpanle0Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                    .addComponent(axilblwrite0, javax.swing.GroupLayout.PREFERRED_SIZE, 26, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addGroup(axiTruputpanle0Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                        .addComponent(axilblread0, javax.swing.GroupLayout.PREFERRED_SIZE, 26, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addComponent(axiRxTextField1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addComponent(axiTxTextField1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)))
                .addContainerGap())
        );

        javax.swing.GroupLayout jPanel5Layout = new javax.swing.GroupLayout(jPanel5);
        jPanel5.setLayout(jPanel5Layout);
        jPanel5Layout.setHorizontalGroup(
            jPanel5Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel5Layout.createSequentialGroup()
                .addGap(6, 6, 6)
                .addGroup(jPanel5Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(jPanel26, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(axiTruputpanle0, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)))
        );
        jPanel5Layout.setVerticalGroup(
            jPanel5Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel5Layout.createSequentialGroup()
                .addGap(0, 0, 0)
                .addComponent(jPanel26, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(axiTruputpanle0, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(5, 5, 5))
        );

        datapathpanel1.setBorder(javax.swing.BorderFactory.createEtchedBorder());

        jPanel32.setBorder(javax.swing.BorderFactory.createTitledBorder("Data Path 1"));

        CheckerChcekBox2.setText("HW Checker");
        CheckerChcekBox2.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                CheckerChcekBox2ActionPerformed(evt);
            }
        });

        GeneratorCheckbox2.setText("HW Generator");
        GeneratorCheckbox2.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                GeneratorCheckbox2ActionPerformed(evt);
            }
        });

        jLabel20.setText("Packet Size (Bytes):");
        jLabel20.setVerticalAlignment(javax.swing.SwingConstants.TOP);

        sizeTextField2.setText("32768");
        sizeTextField2.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                sizeTextField2ActionPerformed(evt);
            }
        });

        jbuttonEngStart2.setText("Start");
        jbuttonEngStart2.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jbuttonEngStart2ActionPerformed(evt);
            }
        });

        loopbackCheckBox2.setText("Loopback");

        javax.swing.GroupLayout jPanel32Layout = new javax.swing.GroupLayout(jPanel32);
        jPanel32.setLayout(jPanel32Layout);
        jPanel32Layout.setHorizontalGroup(
            jPanel32Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel32Layout.createSequentialGroup()
                .addGap(44, 44, 44)
                .addGroup(jPanel32Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(GeneratorCheckbox2)
                    .addGroup(jPanel32Layout.createSequentialGroup()
                        .addGroup(jPanel32Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(CheckerChcekBox2)
                            .addComponent(loopbackCheckBox2))
                        .addGap(32, 32, 32)
                        .addComponent(jLabel20)))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(sizeTextField2, javax.swing.GroupLayout.PREFERRED_SIZE, 82, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(18, 18, 18)
                .addComponent(jbuttonEngStart2)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );
        jPanel32Layout.setVerticalGroup(
            jPanel32Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel32Layout.createSequentialGroup()
                .addGroup(jPanel32Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(jPanel32Layout.createSequentialGroup()
                        .addGap(13, 13, 13)
                        .addGroup(jPanel32Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                            .addComponent(sizeTextField2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addComponent(jbuttonEngStart2)))
                    .addGroup(jPanel32Layout.createSequentialGroup()
                        .addComponent(loopbackCheckBox2)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(CheckerChcekBox2, javax.swing.GroupLayout.PREFERRED_SIZE, 14, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addComponent(jLabel20, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.PREFERRED_SIZE, 24, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(GeneratorCheckbox2, javax.swing.GroupLayout.PREFERRED_SIZE, 18, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(6, 6, 6))
        );

        axiTruputpanle1.setBorder(javax.swing.BorderFactory.createTitledBorder("AXI Throughput"));

        axilblwrite1.setText("AXI-Writes (in Gbps):");
        axilblwrite1.setToolTipText("");

        axiTxTextField2.setEditable(false);
        axiTxTextField2.setText("00.000");

        axiRxTextField2.setEditable(false);
        axiRxTextField2.setText("00.000");

        axilblread1.setText("AXI-Reads (in Gbps):");
        axilblread1.setToolTipText("");

        javax.swing.GroupLayout axiTruputpanle1Layout = new javax.swing.GroupLayout(axiTruputpanle1);
        axiTruputpanle1.setLayout(axiTruputpanle1Layout);
        axiTruputpanle1Layout.setHorizontalGroup(
            axiTruputpanle1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(axiTruputpanle1Layout.createSequentialGroup()
                .addGap(6, 6, 6)
                .addComponent(axilblwrite1, javax.swing.GroupLayout.PREFERRED_SIZE, 161, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(axiTxTextField2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addComponent(axilblread1, javax.swing.GroupLayout.PREFERRED_SIZE, 156, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(axiRxTextField2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(4, 4, 4))
        );
        axiTruputpanle1Layout.setVerticalGroup(
            axiTruputpanle1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, axiTruputpanle1Layout.createSequentialGroup()
                .addContainerGap(13, Short.MAX_VALUE)
                .addGroup(axiTruputpanle1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                    .addComponent(axilblwrite1, javax.swing.GroupLayout.PREFERRED_SIZE, 26, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addGroup(axiTruputpanle1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                        .addComponent(axilblread1, javax.swing.GroupLayout.PREFERRED_SIZE, 26, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addComponent(axiRxTextField2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addComponent(axiTxTextField2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)))
                .addContainerGap())
        );

        javax.swing.GroupLayout datapathpanel1Layout = new javax.swing.GroupLayout(datapathpanel1);
        datapathpanel1.setLayout(datapathpanel1Layout);
        datapathpanel1Layout.setHorizontalGroup(
            datapathpanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(datapathpanel1Layout.createSequentialGroup()
                .addGap(6, 6, 6)
                .addGroup(datapathpanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(jPanel32, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(axiTruputpanle1, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)))
        );
        datapathpanel1Layout.setVerticalGroup(
            datapathpanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(datapathpanel1Layout.createSequentialGroup()
                .addGap(0, 0, 0)
                .addComponent(jPanel32, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(axiTruputpanle1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(5, 5, 5))
        );

        javax.swing.GroupLayout DataPathPanelForOneECLayout = new javax.swing.GroupLayout(DataPathPanelForOneEC);
        DataPathPanelForOneEC.setLayout(DataPathPanelForOneECLayout);
        DataPathPanelForOneECLayout.setHorizontalGroup(
            DataPathPanelForOneECLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, DataPathPanelForOneECLayout.createSequentialGroup()
                .addContainerGap()
                .addGroup(DataPathPanelForOneECLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                    .addComponent(jPanel30, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(jPanel5, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(datapathpanel1, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
                .addContainerGap())
        );
        DataPathPanelForOneECLayout.setVerticalGroup(
            DataPathPanelForOneECLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, DataPathPanelForOneECLayout.createSequentialGroup()
                .addContainerGap()
                .addComponent(jPanel5, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(datapathpanel1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jPanel30, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        DataPathPanelForOneEC_GC.setPreferredSize(new java.awt.Dimension(364, 404));

        jPanel31.setBorder(javax.swing.BorderFactory.createTitledBorder("PCIe Throughput"));

        jLabel30.setText("Transmit (Writes in Gbps):");

        pcieTxTextField3.setEditable(false);
        pcieTxTextField3.setText("00.000");

        pcieRxTextField3.setEditable(false);
        pcieRxTextField3.setText("00.000");

        jLabel31.setText("Receive (Reads in Gbps):");

        javax.swing.GroupLayout jPanel31Layout = new javax.swing.GroupLayout(jPanel31);
        jPanel31.setLayout(jPanel31Layout);
        jPanel31Layout.setHorizontalGroup(
            jPanel31Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel31Layout.createSequentialGroup()
                .addGap(6, 6, 6)
                .addComponent(jLabel30)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(pcieTxTextField3, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addComponent(jLabel31)
                .addGap(3, 3, 3)
                .addComponent(pcieRxTextField3, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(4, 4, 4))
        );
        jPanel31Layout.setVerticalGroup(
            jPanel31Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, jPanel31Layout.createSequentialGroup()
                .addContainerGap(23, Short.MAX_VALUE)
                .addGroup(jPanel31Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(jPanel31Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                        .addComponent(jLabel31, javax.swing.GroupLayout.PREFERRED_SIZE, 26, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addComponent(pcieRxTextField3, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(jPanel31Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                        .addComponent(jLabel30, javax.swing.GroupLayout.PREFERRED_SIZE, 26, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addComponent(pcieTxTextField3, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)))
                .addContainerGap())
        );

        jPanel33.setBorder(javax.swing.BorderFactory.createTitledBorder("Test Control"));

        CheckerChcekBox3.setSelected(true);
        CheckerChcekBox3.setText("System to Card");
        CheckerChcekBox3.setToolTipText("Traffic from host memory to endpoint card");
        CheckerChcekBox3.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                CheckerChcekBox3ActionPerformed(evt);
            }
        });

        GeneratorCheckbox3.setText("Card to System");
        GeneratorCheckbox3.setToolTipText("Traffic from endpoint card to host memory");
        GeneratorCheckbox3.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                GeneratorCheckbox3ActionPerformed(evt);
            }
        });

        jLabel32.setText("Packet Size (Bytes):");

        sizeTextField3.setText("32768");
        sizeTextField3.setToolTipText("64 to 32768");
        sizeTextField3.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                sizeTextField3ActionPerformed(evt);
            }
        });

        jbuttonEngStart3.setText("Start");
        jbuttonEngStart3.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jbuttonEngStart3ActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout jPanel33Layout = new javax.swing.GroupLayout(jPanel33);
        jPanel33.setLayout(jPanel33Layout);
        jPanel33Layout.setHorizontalGroup(
            jPanel33Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel33Layout.createSequentialGroup()
                .addGap(45, 45, 45)
                .addGroup(jPanel33Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(jPanel33Layout.createSequentialGroup()
                        .addComponent(CheckerChcekBox3)
                        .addGap(31, 31, 31)
                        .addComponent(jLabel32)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(sizeTextField3, javax.swing.GroupLayout.PREFERRED_SIZE, 82, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addComponent(GeneratorCheckbox3))
                .addGap(18, 18, 18)
                .addComponent(jbuttonEngStart3, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addContainerGap())
        );
        jPanel33Layout.setVerticalGroup(
            jPanel33Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel33Layout.createSequentialGroup()
                .addGroup(jPanel33Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(jPanel33Layout.createSequentialGroup()
                        .addGap(5, 5, 5)
                        .addComponent(CheckerChcekBox3, javax.swing.GroupLayout.PREFERRED_SIZE, 14, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(GeneratorCheckbox3, javax.swing.GroupLayout.PREFERRED_SIZE, 18, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(jPanel33Layout.createSequentialGroup()
                        .addContainerGap()
                        .addGroup(jPanel33Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(sizeTextField3, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addGroup(jPanel33Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                                .addComponent(jLabel32)
                                .addComponent(jbuttonEngStart3)))))
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        messagelogPanel1.setBorder(javax.swing.BorderFactory.createTitledBorder("Message log"));
        messagelogPanel1.setPreferredSize(new java.awt.Dimension(294, 139));

        jScrollPane7.setHorizontalScrollBarPolicy(javax.swing.ScrollPaneConstants.HORIZONTAL_SCROLLBAR_NEVER);

        messageLog1.setEditable(false);
        messageLog1.setColumns(20);
        messageLog1.setRows(5);
        jScrollPane7.setViewportView(messageLog1);

        javax.swing.GroupLayout messagelogPanel1Layout = new javax.swing.GroupLayout(messagelogPanel1);
        messagelogPanel1.setLayout(messagelogPanel1Layout);
        messagelogPanel1Layout.setHorizontalGroup(
            messagelogPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jScrollPane7)
        );
        messagelogPanel1Layout.setVerticalGroup(
            messagelogPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jScrollPane7, javax.swing.GroupLayout.DEFAULT_SIZE, 199, Short.MAX_VALUE)
        );

        jPanel34.setBorder(javax.swing.BorderFactory.createTitledBorder("AXI Throughput"));

        jLabel33.setText("System to Card (in Gbps):");
        jLabel33.setToolTipText("");

        axiTxTextField3.setEditable(false);
        axiTxTextField3.setText("00.000");

        axiRxTextField3.setEditable(false);
        axiRxTextField3.setText("00.000");

        jLabel34.setText("Card to System (in Gbps):");
        jLabel34.setToolTipText("");

        javax.swing.GroupLayout jPanel34Layout = new javax.swing.GroupLayout(jPanel34);
        jPanel34.setLayout(jPanel34Layout);
        jPanel34Layout.setHorizontalGroup(
            jPanel34Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel34Layout.createSequentialGroup()
                .addGap(6, 6, 6)
                .addComponent(jLabel33)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(axiTxTextField3, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addComponent(jLabel34)
                .addGap(4, 4, 4)
                .addComponent(axiRxTextField3, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(4, 4, 4))
        );
        jPanel34Layout.setVerticalGroup(
            jPanel34Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel34Layout.createSequentialGroup()
                .addContainerGap(21, Short.MAX_VALUE)
                .addGroup(jPanel34Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, jPanel34Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                        .addComponent(jLabel34, javax.swing.GroupLayout.PREFERRED_SIZE, 26, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addComponent(axiRxTextField3, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addComponent(axiTxTextField3, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addComponent(jLabel33, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.PREFERRED_SIZE, 26, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addContainerGap())
        );

        javax.swing.GroupLayout DataPathPanelForOneEC_GCLayout = new javax.swing.GroupLayout(DataPathPanelForOneEC_GC);
        DataPathPanelForOneEC_GC.setLayout(DataPathPanelForOneEC_GCLayout);
        DataPathPanelForOneEC_GCLayout.setHorizontalGroup(
            DataPathPanelForOneEC_GCLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(DataPathPanelForOneEC_GCLayout.createSequentialGroup()
                .addContainerGap()
                .addGroup(DataPathPanelForOneEC_GCLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(messagelogPanel1, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.DEFAULT_SIZE, 512, Short.MAX_VALUE)
                    .addComponent(jPanel33, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(jPanel31, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(jPanel34, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)))
        );
        DataPathPanelForOneEC_GCLayout.setVerticalGroup(
            DataPathPanelForOneEC_GCLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, DataPathPanelForOneEC_GCLayout.createSequentialGroup()
                .addGap(11, 11, 11)
                .addComponent(jPanel33, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jPanel31, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jPanel34, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(messagelogPanel1, javax.swing.GroupLayout.PREFERRED_SIZE, 227, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        tempvaluePanel1.setBackground(java.awt.Color.black);
        tempvaluePanel1.setBorder(javax.swing.BorderFactory.createBevelBorder(javax.swing.border.BevelBorder.RAISED));
        tempvaluePanel1.setToolTipText("Temp");

        TempMeasureLabel1.setBackground(java.awt.Color.black);

        javax.swing.GroupLayout tempvaluePanel1Layout = new javax.swing.GroupLayout(tempvaluePanel1);
        tempvaluePanel1.setLayout(tempvaluePanel1Layout);
        tempvaluePanel1Layout.setHorizontalGroup(
            tempvaluePanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, tempvaluePanel1Layout.createSequentialGroup()
                .addContainerGap(117, Short.MAX_VALUE)
                .addComponent(MajorTempLabel2, javax.swing.GroupLayout.PREFERRED_SIZE, 25, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 0, 0)
                .addComponent(MajorTempLabel1, javax.swing.GroupLayout.PREFERRED_SIZE, 25, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 0, 0)
                .addComponent(MinorTempLabel1, javax.swing.GroupLayout.PREFERRED_SIZE, 25, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 0, 0)
                .addComponent(TempMeasureLabel1, javax.swing.GroupLayout.PREFERRED_SIZE, 25, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 0, 0))
        );
        tempvaluePanel1Layout.setVerticalGroup(
            tempvaluePanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, tempvaluePanel1Layout.createSequentialGroup()
                .addGap(0, 0, 0)
                .addGroup(tempvaluePanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(MajorTempLabel2, javax.swing.GroupLayout.PREFERRED_SIZE, 31, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(MinorTempLabel1, javax.swing.GroupLayout.PREFERRED_SIZE, 31, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(TempMeasureLabel1, javax.swing.GroupLayout.PREFERRED_SIZE, 31, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(MajorTempLabel1, javax.swing.GroupLayout.PREFERRED_SIZE, 31, javax.swing.GroupLayout.PREFERRED_SIZE)))
        );

        javax.swing.GroupLayout jPanel4Layout = new javax.swing.GroupLayout(jPanel4);
        jPanel4.setLayout(jPanel4Layout);
        jPanel4Layout.setHorizontalGroup(
            jPanel4Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel4Layout.createSequentialGroup()
                .addGap(155, 155, 155)
                .addComponent(tempvaluePanel1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(298, Short.MAX_VALUE))
        );
        jPanel4Layout.setVerticalGroup(
            jPanel4Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel4Layout.createSequentialGroup()
                .addGap(177, 177, 177)
                .addComponent(tempvaluePanel1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(154, Short.MAX_VALUE))
        );

        setDefaultCloseOperation(javax.swing.WindowConstants.DO_NOTHING_ON_CLOSE);
        setTitle("Kintex UltraScale PCIe Design Control & Monitoring GUI");
        setResizable(false);
        addWindowListener(new java.awt.event.WindowAdapter() {
            public void windowClosing(java.awt.event.WindowEvent evt) {
                MainScreen.this.windowClosing(evt);
            }
        });

        javax.swing.GroupLayout ControlPanelLayout = new javax.swing.GroupLayout(ControlPanel);
        ControlPanel.setLayout(ControlPanelLayout);
        ControlPanelLayout.setHorizontalGroup(
            ControlPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 518, Short.MAX_VALUE)
        );
        ControlPanelLayout.setVerticalGroup(
            ControlPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 567, Short.MAX_VALUE)
        );

        logscrollpanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Message Log"));

        logArea.setEditable(false);
        logArea.setColumns(20);
        logArea.setRows(5);
        logscrollpanel.setViewportView(logArea);

        phy0icon.setIcon(new javax.swing.ImageIcon(getClass().getResource("/com/xilinx/ultrascale/gui/gray.png"))); // NOI18N

        phy0label.setText("10G PHY-0");

        javax.swing.GroupLayout phy0panelLayout = new javax.swing.GroupLayout(phy0panel);
        phy0panel.setLayout(phy0panelLayout);
        phy0panelLayout.setHorizontalGroup(
            phy0panelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(phy0panelLayout.createSequentialGroup()
                .addContainerGap()
                .addComponent(phy0icon, javax.swing.GroupLayout.PREFERRED_SIZE, 16, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(phy0label)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );
        phy0panelLayout.setVerticalGroup(
            phy0panelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, phy0panelLayout.createSequentialGroup()
                .addGap(0, 0, Short.MAX_VALUE)
                .addGroup(phy0panelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                    .addComponent(phy0label, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(phy0icon, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)))
        );

        phy1icon.setIcon(new javax.swing.ImageIcon(getClass().getResource("/com/xilinx/ultrascale/gui/gray.png"))); // NOI18N

        phty1label.setText("10G PHY-1");

        javax.swing.GroupLayout phy1panelLayout = new javax.swing.GroupLayout(phy1panel);
        phy1panel.setLayout(phy1panelLayout);
        phy1panelLayout.setHorizontalGroup(
            phy1panelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(phy1panelLayout.createSequentialGroup()
                .addContainerGap()
                .addComponent(phy1icon, javax.swing.GroupLayout.PREFERRED_SIZE, 16, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(phty1label)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );
        phy1panelLayout.setVerticalGroup(
            phy1panelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, phy1panelLayout.createSequentialGroup()
                .addGap(0, 0, Short.MAX_VALUE)
                .addGroup(phy1panelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                    .addComponent(phty1label, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(phy1icon, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)))
        );

        DDR4label.setText("DDR4 Calibration");

        javax.swing.GroupLayout ddrpanelLayout = new javax.swing.GroupLayout(ddrpanel);
        ddrpanel.setLayout(ddrpanelLayout);
        ddrpanelLayout.setHorizontalGroup(
            ddrpanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(ddrpanelLayout.createSequentialGroup()
                .addContainerGap()
                .addComponent(ddricon, javax.swing.GroupLayout.PREFERRED_SIZE, 16, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(DDR4label, javax.swing.GroupLayout.DEFAULT_SIZE, 125, Short.MAX_VALUE))
        );
        ddrpanelLayout.setVerticalGroup(
            ddrpanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, ddrpanelLayout.createSequentialGroup()
                .addGap(0, 0, Short.MAX_VALUE)
                .addGroup(ddrpanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                    .addComponent(DDR4label, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(ddricon, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)))
        );

        javax.swing.GroupLayout ledPanelLayout = new javax.swing.GroupLayout(ledPanel);
        ledPanel.setLayout(ledPanelLayout);
        ledPanelLayout.setHorizontalGroup(
            ledPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(ledPanelLayout.createSequentialGroup()
                .addGap(63, 63, 63)
                .addComponent(phy0panel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(ddrpanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(15, 15, 15)
                .addComponent(phy1panel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(45, Short.MAX_VALUE))
        );
        ledPanelLayout.setVerticalGroup(
            ledPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(phy0panel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
            .addComponent(phy1panel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
            .addComponent(ddrpanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
        );

        javax.swing.GroupLayout DyPanelLayout = new javax.swing.GroupLayout(DyPanel);
        DyPanel.setLayout(DyPanelLayout);
        DyPanelLayout.setHorizontalGroup(
            DyPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(DyPanelLayout.createSequentialGroup()
                .addGap(0, 0, 0)
                .addGroup(DyPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(ledPanel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(logscrollpanel)
                    .addComponent(ControlPanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)))
        );
        DyPanelLayout.setVerticalGroup(
            DyPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(DyPanelLayout.createSequentialGroup()
                .addContainerGap()
                .addComponent(ledPanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(ControlPanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addComponent(logscrollpanel, javax.swing.GroupLayout.PREFERRED_SIZE, 0, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 0, 0))
        );

        javax.swing.GroupLayout topChartperfpanelLayout = new javax.swing.GroupLayout(topChartperfpanel);
        topChartperfpanel.setLayout(topChartperfpanelLayout);
        topChartperfpanelLayout.setHorizontalGroup(
            topChartperfpanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 605, Short.MAX_VALUE)
        );
        topChartperfpanelLayout.setVerticalGroup(
            topChartperfpanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 256, Short.MAX_VALUE)
        );

        javax.swing.GroupLayout bottomChartperfpanelLayout = new javax.swing.GroupLayout(bottomChartperfpanel);
        bottomChartperfpanel.setLayout(bottomChartperfpanelLayout);
        bottomChartperfpanelLayout.setHorizontalGroup(
            bottomChartperfpanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 605, Short.MAX_VALUE)
        );
        bottomChartperfpanelLayout.setVerticalGroup(
            bottomChartperfpanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 246, Short.MAX_VALUE)
        );

        javax.swing.GroupLayout PerformancePlotTabLayout = new javax.swing.GroupLayout(PerformancePlotTab);
        PerformancePlotTab.setLayout(PerformancePlotTabLayout);
        PerformancePlotTabLayout.setHorizontalGroup(
            PerformancePlotTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(PerformancePlotTabLayout.createSequentialGroup()
                .addContainerGap()
                .addGroup(PerformancePlotTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(topChartperfpanel, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(bottomChartperfpanel, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
                .addContainerGap())
        );
        PerformancePlotTabLayout.setVerticalGroup(
            PerformancePlotTabLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(PerformancePlotTabLayout.createSequentialGroup()
                .addContainerGap()
                .addComponent(topChartperfpanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(bottomChartperfpanel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addGap(18, 18, 18))
        );

        tabbedPanel.addTab("Performance Plots", PerformancePlotTab);

        tempvaluePanel.setBackground(java.awt.Color.black);
        tempvaluePanel.setBorder(javax.swing.BorderFactory.createBevelBorder(javax.swing.border.BevelBorder.RAISED));
        tempvaluePanel.setToolTipText("Temp");

        TempMeasureLabel.setBackground(java.awt.Color.black);

        javax.swing.GroupLayout tempvaluePanelLayout = new javax.swing.GroupLayout(tempvaluePanel);
        tempvaluePanel.setLayout(tempvaluePanelLayout);
        tempvaluePanelLayout.setHorizontalGroup(
            tempvaluePanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, tempvaluePanelLayout.createSequentialGroup()
                .addGap(0, 0, Short.MAX_VALUE)
                .addComponent(MajorTempLabel3, javax.swing.GroupLayout.PREFERRED_SIZE, 25, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 0, 0)
                .addComponent(MajorTempLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 25, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 0, 0)
                .addComponent(MinorTempLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 25, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 0, 0)
                .addComponent(TempMeasureLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 25, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(0, 0, 0))
        );
        tempvaluePanelLayout.setVerticalGroup(
            tempvaluePanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, tempvaluePanelLayout.createSequentialGroup()
                .addGap(0, 0, Short.MAX_VALUE)
                .addGroup(tempvaluePanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                    .addComponent(MinorTempLabel, javax.swing.GroupLayout.DEFAULT_SIZE, 31, Short.MAX_VALUE)
                    .addComponent(TempMeasureLabel, javax.swing.GroupLayout.DEFAULT_SIZE, 31, Short.MAX_VALUE)
                    .addComponent(MajorTempLabel, javax.swing.GroupLayout.DEFAULT_SIZE, 31, Short.MAX_VALUE)
                    .addComponent(MajorTempLabel3, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)))
        );

        jLabel1.setFont(new java.awt.Font("Tahoma", 1, 12)); // NOI18N
        jLabel1.setText("Die Temperature :");

        javax.swing.GroupLayout tempholdPanelLayout = new javax.swing.GroupLayout(tempholdPanel);
        tempholdPanel.setLayout(tempholdPanelLayout);
        tempholdPanelLayout.setHorizontalGroup(
            tempholdPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, tempholdPanelLayout.createSequentialGroup()
                .addGap(23, 23, 23)
                .addComponent(jLabel1, javax.swing.GroupLayout.DEFAULT_SIZE, 136, Short.MAX_VALUE)
                .addGap(18, 18, 18)
                .addComponent(tempvaluePanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap())
        );
        tempholdPanelLayout.setVerticalGroup(
            tempholdPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, tempholdPanelLayout.createSequentialGroup()
                .addGap(0, 4, Short.MAX_VALUE)
                .addGroup(tempholdPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(jLabel1, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(tempvaluePanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)))
        );

        PowerPanel.setBorder(javax.swing.BorderFactory.createTitledBorder(""));

        javax.swing.GroupLayout PowerPanelLayout = new javax.swing.GroupLayout(PowerPanel);
        PowerPanel.setLayout(PowerPanelLayout);
        PowerPanelLayout.setHorizontalGroup(
            PowerPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 350, Short.MAX_VALUE)
        );
        PowerPanelLayout.setVerticalGroup(
            PowerPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 458, Short.MAX_VALUE)
        );

        jPanel1.setPreferredSize(new java.awt.Dimension(21, 519));

        PcieEndStatuspanel.setBorder(javax.swing.BorderFactory.createTitledBorder("PCIe Endpoint Status"));

        pcieSysmontable.setModel(new javax.swing.table.DefaultTableModel(
            new Object [][] {
                {"Link State", "Up"},
                {"Link Speed", "5 Gbps"},
                {"Link Width", "x8"},
                {"Interrupts", "Legacy"},
                {"Vendor ID", "0x10ee"},
                {"Device ID", "0x7082"},
                {"MPS(Bytes)", "128"},
                {"MRPS(Bytes)", "512"}
            },
            new String [] {
                "Type", "Value"
            }
        ) {
            boolean[] canEdit = new boolean [] {
                false, false
            };

            public boolean isCellEditable(int rowIndex, int columnIndex) {
                return canEdit [columnIndex];
            }
        });
        pcieSysmontable.setRowSelectionAllowed(false);
        jScrollPane2.setViewportView(pcieSysmontable);

        javax.swing.GroupLayout PcieEndStatuspanelLayout = new javax.swing.GroupLayout(PcieEndStatuspanel);
        PcieEndStatuspanel.setLayout(PcieEndStatuspanelLayout);
        PcieEndStatuspanelLayout.setHorizontalGroup(
            PcieEndStatuspanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(PcieEndStatuspanelLayout.createSequentialGroup()
                .addContainerGap()
                .addComponent(jScrollPane2, javax.swing.GroupLayout.PREFERRED_SIZE, 0, Short.MAX_VALUE)
                .addContainerGap())
        );
        PcieEndStatuspanelLayout.setVerticalGroup(
            PcieEndStatuspanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(PcieEndStatuspanelLayout.createSequentialGroup()
                .addComponent(jScrollPane2, javax.swing.GroupLayout.DEFAULT_SIZE, 209, Short.MAX_VALUE)
                .addContainerGap())
        );

        hostCreditsPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Host System's Initial Credits"));

        hostsysmontable.setModel(new javax.swing.table.DefaultTableModel(
            new Object [][] {
                {"Posted Header", "96"},
                {"Non Posted Header", "96"},
                {"Completion Header", "0"},
                {null, null},
                {null, null},
                {"Posted Data", "432"},
                {"Non Posted Data", "16"},
                {"Completion Data", "0"}
            },
            new String [] {
                "Type", "Value"
            }
        ) {
            boolean[] canEdit = new boolean [] {
                false, false
            };

            public boolean isCellEditable(int rowIndex, int columnIndex) {
                return canEdit [columnIndex];
            }
        });
        hostsysmontable.setRowSelectionAllowed(false);
        jScrollPane3.setViewportView(hostsysmontable);

        javax.swing.GroupLayout hostCreditsPanelLayout = new javax.swing.GroupLayout(hostCreditsPanel);
        hostCreditsPanel.setLayout(hostCreditsPanelLayout);
        hostCreditsPanelLayout.setHorizontalGroup(
            hostCreditsPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(hostCreditsPanelLayout.createSequentialGroup()
                .addContainerGap()
                .addComponent(jScrollPane3, javax.swing.GroupLayout.DEFAULT_SIZE, 212, Short.MAX_VALUE)
                .addContainerGap())
        );
        hostCreditsPanelLayout.setVerticalGroup(
            hostCreditsPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(hostCreditsPanelLayout.createSequentialGroup()
                .addComponent(jScrollPane3, javax.swing.GroupLayout.DEFAULT_SIZE, 177, Short.MAX_VALUE)
                .addContainerGap())
        );

        javax.swing.GroupLayout jPanel1Layout = new javax.swing.GroupLayout(jPanel1);
        jPanel1.setLayout(jPanel1Layout);
        jPanel1Layout.setHorizontalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(hostCreditsPanel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(PcieEndStatuspanel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
        );
        jPanel1Layout.setVerticalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel1Layout.createSequentialGroup()
                .addContainerGap(31, Short.MAX_VALUE)
                .addComponent(PcieEndStatuspanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(hostCreditsPanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
        );

        javax.swing.GroupLayout jPanel2Layout = new javax.swing.GroupLayout(jPanel2);
        jPanel2.setLayout(jPanel2Layout);
        jPanel2Layout.setHorizontalGroup(
            jPanel2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 250, Short.MAX_VALUE)
        );
        jPanel2Layout.setVerticalGroup(
            jPanel2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 16, Short.MAX_VALUE)
        );

        javax.swing.GroupLayout sysmonpanelLayout = new javax.swing.GroupLayout(sysmonpanel);
        sysmonpanel.setLayout(sysmonpanelLayout);
        sysmonpanelLayout.setHorizontalGroup(
            sysmonpanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(sysmonpanelLayout.createSequentialGroup()
                .addGap(21, 21, 21)
                .addComponent(jPanel2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(266, 350, Short.MAX_VALUE))
            .addGroup(sysmonpanelLayout.createSequentialGroup()
                .addContainerGap()
                .addComponent(jPanel1, javax.swing.GroupLayout.PREFERRED_SIZE, 246, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGroup(sysmonpanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(sysmonpanelLayout.createSequentialGroup()
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(PowerPanel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                        .addGap(5, 5, 5))
                    .addGroup(sysmonpanelLayout.createSequentialGroup()
                        .addGap(23, 23, 23)
                        .addComponent(tempholdPanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))))
        );
        sysmonpanelLayout.setVerticalGroup(
            sysmonpanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(sysmonpanelLayout.createSequentialGroup()
                .addGap(6, 6, 6)
                .addGroup(sysmonpanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(sysmonpanelLayout.createSequentialGroup()
                        .addComponent(tempholdPanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(PowerPanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, sysmonpanelLayout.createSequentialGroup()
                        .addGap(6, 6, 6)
                        .addComponent(jPanel1, javax.swing.GroupLayout.PREFERRED_SIZE, 509, javax.swing.GroupLayout.PREFERRED_SIZE)))
                .addGap(474, 474, 474)
                .addComponent(jPanel2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        tabbedPanel.addTab("SYSMON & PCIe Info", sysmonpanel);

        javax.swing.GroupLayout statusPanelLayout = new javax.swing.GroupLayout(statusPanel);
        statusPanel.setLayout(statusPanelLayout);
        statusPanelLayout.setHorizontalGroup(
            statusPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 629, Short.MAX_VALUE)
        );
        statusPanelLayout.setVerticalGroup(
            statusPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 544, Short.MAX_VALUE)
        );

        tabbedPanel.addTab("Status and Credits", statusPanel);

        javax.swing.GroupLayout tabpanelLayout = new javax.swing.GroupLayout(tabpanel);
        tabpanel.setLayout(tabpanelLayout);
        tabpanelLayout.setHorizontalGroup(
            tabpanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(tabpanelLayout.createSequentialGroup()
                .addContainerGap()
                .addComponent(tabbedPanel, javax.swing.GroupLayout.PREFERRED_SIZE, 641, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );
        tabpanelLayout.setVerticalGroup(
            tabpanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(tabpanelLayout.createSequentialGroup()
                .addContainerGap()
                .addComponent(tabbedPanel, javax.swing.GroupLayout.PREFERRED_SIZE, 589, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        tabbedPanel.getAccessibleContext().setAccessibleName("System Monitor");

        headinglable.setFont(new java.awt.Font("Tahoma", 1, 14)); // NOI18N
        headinglable.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
        headinglable.setText("Performance Mode (GEN/CHK)");

        blockdiagrambutton.setText("Block Diagram");
        blockdiagrambutton.setActionCommand("<html><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>B<br>l<br>o<br>c<br>k<br><br>D<br>i<br>a<br>g<br>r<br>a<br>m</html>");
        blockdiagrambutton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                blockdiagrambuttonActionPerformed(evt);
            }
        });

        jLabel3.setIcon(new javax.swing.ImageIcon(getClass().getResource("/com/xilinx/ultrascale/gui/xlogo_bg.jpg"))); // NOI18N

        jLabel5.setIcon(new javax.swing.ImageIcon(getClass().getResource("/com/xilinx/ultrascale/gui/KintexUltra.jpg"))); // NOI18N

        javax.swing.GroupLayout HeadingPanelLayout = new javax.swing.GroupLayout(HeadingPanel);
        HeadingPanel.setLayout(HeadingPanelLayout);
        HeadingPanelLayout.setHorizontalGroup(
            HeadingPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(HeadingPanelLayout.createSequentialGroup()
                .addComponent(jLabel5)
                .addGap(134, 134, 134)
                .addComponent(headinglable, javax.swing.GroupLayout.PREFERRED_SIZE, 616, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addComponent(blockdiagrambutton, javax.swing.GroupLayout.PREFERRED_SIZE, 125, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(29, 29, 29)
                .addComponent(jLabel3))
        );
        HeadingPanelLayout.setVerticalGroup(
            HeadingPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(HeadingPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                .addComponent(headinglable, javax.swing.GroupLayout.PREFERRED_SIZE, 40, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addComponent(blockdiagrambutton, javax.swing.GroupLayout.PREFERRED_SIZE, 27, javax.swing.GroupLayout.PREFERRED_SIZE))
            .addComponent(jLabel3, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.PREFERRED_SIZE, 40, javax.swing.GroupLayout.PREFERRED_SIZE)
            .addComponent(jLabel5, javax.swing.GroupLayout.PREFERRED_SIZE, 40, javax.swing.GroupLayout.PREFERRED_SIZE)
        );

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING, false)
                    .addGroup(layout.createSequentialGroup()
                        .addContainerGap()
                        .addComponent(HeadingPanel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
                    .addGroup(javax.swing.GroupLayout.Alignment.LEADING, layout.createSequentialGroup()
                        .addComponent(DyPanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(0, 0, 0)
                        .addComponent(tabpanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)))
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addComponent(HeadingPanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(DyPanel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addGroup(layout.createSequentialGroup()
                        .addComponent(tabpanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(0, 0, Short.MAX_VALUE)))
                .addContainerGap())
        );

        pack();
    }// </editor-fold>//GEN-END:initComponents

    private void jCheckBox1ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jCheckBox1ActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_jCheckBox1ActionPerformed

    private void jCheckBox2ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jCheckBox2ActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_jCheckBox2ActionPerformed

    private void jCheckBox4ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jCheckBox4ActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_jCheckBox4ActionPerformed

    private void jCheckBox5ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jCheckBox5ActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_jCheckBox5ActionPerformed

    private void windowClosing(java.awt.event.WindowEvent evt) {//GEN-FIRST:event_windowClosing
        // TODO add your handling code here:
        //powerTimer.cancel();
        Object[] options1 = {"No", "Yes"};
        int s = JOptionPane.showOptionDialog(null, "This will uninstall Device Drivers. Are you sure?", " ",
                JOptionPane.CLOSED_OPTION, JOptionPane.QUESTION_MESSAGE,
                null, options1, null);

        if (s == 1) {
            timer.cancel();
            if (testStarted) {
                testStarted = false;
                jbuttonEngStart.setText("Start");
                int size = Integer.parseInt(sizeTextField.getText());
                di.stopTest(0, testMode, size);
            }
            if (ethTestStarted0) {
                ethTestStarted0 = false;
                jbuttonEngStart1.setText("Start");
                int size = Integer.parseInt(sizeTextField1.getText());
                di.stopTest(0, eth0TestMode, size);
            }
            if (ethTestStarted1) {
                ethTestStarted1 = false;
                jbuttonEngStart2.setText("Start");
                int size = Integer.parseInt(sizeTextField2.getText());
                di.stopTest(0, eth1TestMode, size);
            }
            System.gc();
            di.flush();
            lp.uninstallDrivers(this);
            showDialog("Removing Device Drivers...Please wait...");
        }
//        lp.showLP();
    }//GEN-LAST:event_windowClosing
    private void updateStats() {
        timer = new java.util.Timer();
        timer.schedule(new TimerTask() {
            @Override
            public void run() {
                makeDMAData();
                updatePowerAndTemp();
            }
        }, 0, 2000);
    }

    public void unInstallDone() {
        modalDialog.setVisible(false);
        lp.showLP();
        this.dispose();
    }
    JDialog modalDialog;

    private void showDialog(String message) {
        modalDialog = new JDialog(this, "Busy", Dialog.ModalityType.DOCUMENT_MODAL);
        JLabel lmessage = new JLabel(message, JLabel.CENTER);

        //modalDialog.add(limg, BorderLayout.LINE_START);
        modalDialog.add(lmessage, BorderLayout.CENTER);
        modalDialog.setSize(400, 150);
        modalDialog.setLocationRelativeTo(this);
        modalDialog.setVisible(true);
    }

    private void CheckerChcekBoxActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_CheckerChcekBoxActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_CheckerChcekBoxActionPerformed

    private void jbuttonEngStartActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jbuttonEngStartActionPerformed
        // TODO add your handling code here:
        try {
            int sizeval = Integer.parseInt(sizeTextField.getText());
            if (sizeval > 32768 || sizeval < 64) {
                JOptionPane.showMessageDialog(this, "Packet size should be in the range 64 to 32768 Bytes");
                sizeTextField.setText("32768");
                return;
            }

        } catch (Exception e) {// alert for invalid chars
            JOptionPane.showMessageDialog(this, "Packet size must be an integer");
            sizeTextField.setText("32768");
            return;
        }
        if (screenMode == 1 && ddrledState == 0) {// check for gencheck with card ddr.
            JOptionPane.showMessageDialog(this, "DDR4 not calibrated. Could not start the test.");
            return;
        }

        if (!CheckerChcekBox.isSelected() && !GeneratorCheckbox.isSelected()) {
            JOptionPane.showMessageDialog(this, "Please select atleast one option in Test Control.");
            return;
        }

        if (jbuttonEngStart.getText().equalsIgnoreCase("Start")) {
            jbuttonEngStart.setText("Stop");
            if (CheckerChcekBox.isSelected()) {
                testMode = DriverInfo.CHECKER;
            }
            if (GeneratorCheckbox.isSelected()) {
                testMode = DriverInfo.GENERATOR;
            }
            if (CheckerChcekBox.isSelected() && GeneratorCheckbox.isSelected()) {
                testMode = DriverInfo.CHECKER_GEN;
            }

            int size = Integer.parseInt(sizeTextField.getText());
            di.startTest(0, testMode, size);
            testStarted = true;
            // Disabling all components
            CheckerChcekBox.setEnabled(false);
            GeneratorCheckbox.setEnabled(false);
            sizeTextField.setEditable(false);
            messageLog.append(">> Test Started\n");

        } else {
            testStarted = false;
            jbuttonEngStart.setText("Start");
            CheckerChcekBox.setEnabled(true);
            GeneratorCheckbox.setEnabled(true);
            sizeTextField.setEditable(true);
            // reset data.
            axiTxTextField.setText("0.000");
            axiRxTextField.setText("0.000");
//            ddrRxTextField.setText("0.000");
//            ddrTxTextField.setText("0.000");

            pcieTxTextField1.setText("0.000");
            pcieRxTextField1.setText("0.000");

            //timer.cancel();
            chartBottom.reset();
            chartTop.reset();
            int size = Integer.parseInt(sizeTextField.getText());
            di.stopTest(0, testMode, size);
            messageLog.append(">> Test Stopped\n");
        }

    }//GEN-LAST:event_jbuttonEngStartActionPerformed

    private void sizeTextFieldActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_sizeTextFieldActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_sizeTextFieldActionPerformed

    private void sizeControlTextFieldActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_sizeControlTextFieldActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_sizeControlTextFieldActionPerformed

    private void barComboBoxbottomActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_barComboBoxbottomActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_barComboBoxbottomActionPerformed

    private void executeRWButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_executeRWButtonActionPerformed
        // TODO add your handling code here:
        // Either read or write.
//        if (readRadioButton.isSelected() == true) {
//            
//        } else {
        // write is selected.
        int bar = 2;
        if (barComboBoxTop.getSelectedItem().equals("Bar2")) {
            bar = 2;
        } else if (barComboBoxTop.getSelectedItem().equals("Bar4")) {
            bar = 4;
        }

        String ofstr = offsetTextField.getText();
        ofstr = ofstr.replaceAll("0x", "");
        int offset = 0;
        try {
            offset = Integer.parseInt(ofstr, 16);
            if (offset % 4 != 0) {// show alert for multiples of zero
                JOptionPane.showMessageDialog(this, "Offset must be a multiple of 4");
                offsetTextField.setText("0x");
                return;
            }
            if (offset >= 0x1000) {
                JOptionPane.showMessageDialog(this, "Max Offset allowed is 0x1000");
                offsetTextField.setText("0x");
                return;
            }
        } catch (Exception e) {// alert for invalid chars
            JOptionPane.showMessageDialog(this, "Offset must be an integer");
            offsetTextField.setText("0x");
            return;
        }
        String data = dataTextfield.getText();
        data = data.replaceAll("0x", "");
        long dataInt = 0;
        try {
            dataInt = Long.parseLong(data, 16);
            /*if (dataInt > 0x10000){
             JOptionPane.showMessageDialog(this, "Max data allowed is 0x10000");
             return;
             }*/
        } catch (Exception e) {// alert for invalid chars
            JOptionPane.showMessageDialog(this, "Data range is 0x0 - 0xFFFFFFFF");
            return;
        }
        di.writeCmd(ms, bar, offset, dataInt);
//        }


    }//GEN-LAST:event_executeRWButtonActionPerformed
    public void fillDataFromRead(int str) {
        dataTextfield1.setText("0x" + Integer.toHexString(str));
    }

    private String leftpad(String s, int l, String p) {
        String tmp = "";
        for (int i = 0; i < l; ++i) {
            tmp = tmp + p;
        }
        return tmp + s;
    }

    public void fillDataDumpFromRead(int[] str) {
        int len = str.length;
        int size = len / 4;
        if (len % 4 > 0) {
            size = size + 1;
        }
        if (size < 14) { // to fill empty rows
            size = 14;
        }
        String[] empty = {"", "", "", "", ""};
        Object[][] bardumpData = new Object[size][5];
        int hindex = 0;
        int index = 1;
        int oindex = 0;
        String hexs = Integer.toHexString(hindex);
        bardumpData[oindex][0] = "0x" + leftpad(hexs, 8 - hexs.length(), "0");
        for (int i = 0; i < str.length; ++i) {
            if (i >= 4 && i % 4 == 0) {
                hindex = hindex + 16;
                hexs = Integer.toHexString(hindex);
                index = 1;
                oindex++;
                bardumpData[oindex][0] = "0x" + leftpad(hexs, 8 - hexs.length(), "0");
            }
            hexs = Integer.toHexString(str[i]);
            bardumpData[oindex][index] = "0x" + leftpad(hexs, 8 - hexs.length(), "0");
            index++;
        }
        // if not exact 4 elements then add the extra ones to here
        for (int i = index; i < 5; ++i) {
            bardumpData[oindex][i] = "";
        }
        // if size is less than 14 add empty values to fill the table
        oindex++;
        for (int i = oindex; i < size; ++i) {
            bardumpData[oindex++] = empty;
        }
        barDumpModel.setData(bardumpData, bardumpNames);
        barDumpModel.fireTableDataChanged();
    }
    private void executeBarButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_executeBarButtonActionPerformed
        // TODO add your handling code here:
        // read  dump data here..
        //System.out.println(" clicked execute button");
        int bar = 2;
        if (barComboBoxbottom.getSelectedItem().equals("Bar2")) {
            bar = 2;
        } else if (barComboBoxbottom.getSelectedItem().equals("Bar4")) {
            bar = 4;
        }
        String address = AddressTextField.getText();
        address = address.replaceAll("0x", "");

        int adrs = 0;
        try {
            adrs = Integer.parseInt(address, 16);

        } catch (Exception e) {// alert for invalid chars

            JOptionPane.showMessageDialog(this, "Offset must be an integer");
            AddressTextField.setText("0x");
            return;
        }
        if (adrs > 0x1000) {
            JOptionPane.showMessageDialog(this, "Max Offset allowed is 0x1000");
            AddressTextField.setText("0x");
            return;
        }
        String vsizestr = sizeControlTextField.getText();
        int sizev = 0;
        try {
            sizev = Integer.parseInt(vsizestr, 10);

            if (sizev == 0) {
                JOptionPane.showMessageDialog(this, "Size must be greater than 0.");
                sizeControlTextField.setText("");
                return;
            } else if (sizev >= 0x1000) {
                JOptionPane.showMessageDialog(this, "Max Size allowed is 4K");
                sizeControlTextField.setText("");
                return;
            } else if (sizev % 4 != 0) {// show alert for multiples of zero
                JOptionPane.showMessageDialog(this, "Size must be a multiple of 4");
                sizeControlTextField.setText("");
                return;
            }

        } catch (Exception e) {// alert for invalid chars
            JOptionPane.showMessageDialog(this, "Size must be an integer.");
            sizeControlTextField.setText("");
            return;
        }

        di.readDump(ms, bar, adrs, sizev);
    }//GEN-LAST:event_executeBarButtonActionPerformed

    private void executeRWButton1ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_executeRWButton1ActionPerformed
        // TODO add your handling code here:
        // reading 
        int bar = 2;
        if (barComboBoxTop1.getSelectedItem().equals("Bar2")) {
            bar = 2;
        } else if (barComboBoxTop1.getSelectedItem().equals("Bar4")) {
            bar = 4;
        }

        String ofstr = offsetTextField1.getText();
        ofstr = ofstr.replaceAll("0x", "");
        int offset = 0;
        try {
            offset = Integer.parseInt(ofstr, 16);
            if (offset % 4 != 0) {// show alert for multiples of zero
                JOptionPane.showMessageDialog(this, "Offset must be a multiple of 4");
                offsetTextField1.setText("0x");
                return;
            }
            if (offset >= 0x1000) {
                JOptionPane.showMessageDialog(this, "Max offset allowed is 0x1000");
                offsetTextField1.setText("0x");
                return;
            }
        } catch (Exception e) {// alert for invalid chars
            JOptionPane.showMessageDialog(this, "Offset must be an integer");
            offsetTextField1.setText("0x");
            return;
        }
        di.readCmd(ms, bar, offset);

    }//GEN-LAST:event_executeRWButton1ActionPerformed

    private void blockdiagrambuttonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_blockdiagrambuttonActionPerformed
        // TODO add your handling code here:
       /* Object[] options1 = {"Close"};
         int s = JOptionPane.showOptionDialog(null, BlockDiagramPanel, "Block Diagram",
         JOptionPane.YES_NO_CANCEL_OPTION, JOptionPane.PLAIN_MESSAGE,
         null, options1, null);*/
        bdFrame.setSize(blockdiagramlbl.getIcon().getIconWidth() + 5, blockdiagramlbl.getIcon().getIconHeight() + 40);
        bdFrame.setLocationRelativeTo(this);

        bdFrame.show();
    }//GEN-LAST:event_blockdiagrambuttonActionPerformed

    private void GeneratorCheckboxActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_GeneratorCheckboxActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_GeneratorCheckboxActionPerformed

    private void CheckerChcekBox1ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_CheckerChcekBox1ActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_CheckerChcekBox1ActionPerformed

    private void GeneratorCheckbox1ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_GeneratorCheckbox1ActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_GeneratorCheckbox1ActionPerformed

    private void sizeTextField1ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_sizeTextField1ActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_sizeTextField1ActionPerformed

    private void jbuttonEngStart1ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jbuttonEngStart1ActionPerformed
        // TODO add your handling code here:
        if (!(screenMode != 3 || screenMode != 4)) {
            if (!CheckerChcekBox1.isSelected() && !GeneratorCheckbox1.isSelected() && !loopbackCheckBox1.isSelected()) {
                JOptionPane.showMessageDialog(this, "Please select atleast one option in Data Path 0.");
                return;
            }

        } else {
            eth1TestMode = DriverInfo.ENABLE_LOOPBACK;
            eth0TestMode = DriverInfo.ENABLE_LOOPBACK;

        }
        if (jbuttonEngStart1.getText().equalsIgnoreCase("Start")) {
            jbuttonEngStart1.setText("Stop");
            if (loopbackCheckBox1.isSelected()) {
                eth0TestMode = DriverInfo.ENABLE_LOOPBACK;
            }
            if (CheckerChcekBox1.isSelected()) {
                eth0TestMode = DriverInfo.CHECKER;
            }
            if (GeneratorCheckbox1.isSelected()) {
                eth0TestMode = DriverInfo.GENERATOR;
            }
            if (CheckerChcekBox1.isSelected() && GeneratorCheckbox1.isSelected()) {
                eth0TestMode = DriverInfo.CHECKER_GEN;
            }
            if (screenMode == 3) {
                eth0TestMode = DriverInfo.ENABLE_LOOPBACK;
            }

            int size = Integer.parseInt(sizeTextField1.getText());
            di.startTest(0, eth0TestMode, size);
            ethTestStarted0 = true;
            // Disabling all components
            loopbackCheckBox1.setEnabled(false);
            CheckerChcekBox1.setEnabled(false);
            GeneratorCheckbox1.setEnabled(false);
            sizeTextField1.setEditable(false);

        } else {
            ethTestStarted0 = false;
            jbuttonEngStart1.setText("Start");
            CheckerChcekBox1.setEnabled(true);
            GeneratorCheckbox1.setEnabled(true);
            loopbackCheckBox1.setEnabled(true);
            sizeTextField1.setEditable(true);
            // reset data.
            axiTxTextField1.setText("0.000");
            axiRxTextField1.setText("0.000");
//            ddrRxTextField.setText("0.000");
//            ddrTxTextField.setText("0.000");

            if (screenMode == 3) {
                axiTxTextField1.setText("0.000");
                axiRxTextField2.setText("0.000");
                if (jbuttonEngStart2.getText().equalsIgnoreCase("start")) {
                    pcieTxTextField2.setText("0.000");
                    pcieRxTextField2.setText("0.000");
                }
            }
            if (ethTestStarted1 == false) {
                pcieTxTextField1.setText("0.000");
                pcieRxTextField1.setText("0.000");

                //timer.cancel();
                chartBottomEth.reset();
                chartTopEth.reset();
            }
            int size = Integer.parseInt(sizeTextField1.getText());
            di.stopTest(0, eth0TestMode, size);
        }

    }//GEN-LAST:event_jbuttonEngStart1ActionPerformed

    private void jbuttonEngStart2ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jbuttonEngStart2ActionPerformed
        // TODO add your handling code here:
        if (!(screenMode != 3 || screenMode != 4)) {
            if (!CheckerChcekBox2.isSelected() && !GeneratorCheckbox2.isSelected() && !loopbackCheckBox2.isSelected()) {
                JOptionPane.showMessageDialog(this, "Please select atleast one option in Data Path 1.");
                return;
            }
        } else {
            eth1TestMode = DriverInfo.ENABLE_LOOPBACK;
            eth0TestMode = DriverInfo.ENABLE_LOOPBACK;

        }

        if (jbuttonEngStart2.getText().equalsIgnoreCase("Start")) {
            jbuttonEngStart2.setText("Stop");
            if (loopbackCheckBox2.isSelected()) {
                eth1TestMode = DriverInfo.ENABLE_LOOPBACK;
            }
            if (CheckerChcekBox2.isSelected()) {
                eth1TestMode = DriverInfo.CHECKER;
            }
            if (GeneratorCheckbox2.isSelected()) {
                eth1TestMode = DriverInfo.GENERATOR;
            }
            if (CheckerChcekBox2.isSelected() && GeneratorCheckbox2.isSelected()) {
                eth1TestMode = DriverInfo.CHECKER_GEN;
            }

            if (screenMode == 3) {
                eth1TestMode = DriverInfo.ENABLE_LOOPBACK;
            }

            int size = Integer.parseInt(sizeTextField2.getText());

            di.startTest1(1, eth1TestMode, size);
            ethTestStarted1 = true;
            // Disabling all components
            loopbackCheckBox2.setEnabled(false);
            CheckerChcekBox2.setEnabled(false);
            GeneratorCheckbox2.setEnabled(false);
            sizeTextField2.setEditable(false);

        } else {
            ethTestStarted1 = false;
            jbuttonEngStart2.setText("Start");
            CheckerChcekBox2.setEnabled(true);
            GeneratorCheckbox2.setEnabled(true);
            loopbackCheckBox2.setEnabled(true);
            sizeTextField2.setEditable(true);
            // reset data.
            axiTxTextField2.setText("0.000");
            axiRxTextField2.setText("0.000");
            //            ddrRxTextField.setText("0.000");
            //            ddrTxTextField.setText("0.000");
            if (screenMode == 3) {
                axiTxTextField2.setText("0.000");
                axiRxTextField1.setText("0.000");
                if (jbuttonEngStart1.getText().equalsIgnoreCase("Start")) {
                    pcieTxTextField2.setText("0.000");
                    pcieRxTextField2.setText("0.000");
                }
            }
            if (ethTestStarted0 == false) {
                pcieTxTextField2.setText("0.000");
                pcieRxTextField2.setText("0.000");

                //timer.cancel();
                chartBottomEth.reset();
                chartTopEth.reset();
            }
            int size = Integer.parseInt(sizeTextField2.getText());
            di.stopTest1(1, eth1TestMode, size);
        }
    }//GEN-LAST:event_jbuttonEngStart2ActionPerformed

    private void sizeTextField2ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_sizeTextField2ActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_sizeTextField2ActionPerformed

    private void GeneratorCheckbox2ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_GeneratorCheckbox2ActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_GeneratorCheckbox2ActionPerformed

    private void CheckerChcekBox2ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_CheckerChcekBox2ActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_CheckerChcekBox2ActionPerformed

    private void CheckerChcekBox3ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_CheckerChcekBox3ActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_CheckerChcekBox3ActionPerformed

    private void GeneratorCheckbox3ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_GeneratorCheckbox3ActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_GeneratorCheckbox3ActionPerformed

    private void sizeTextField3ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_sizeTextField3ActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_sizeTextField3ActionPerformed

    private void jbuttonEngStart3ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jbuttonEngStart3ActionPerformed
        // TODO add your handling code here:
        try {
            int sizeval = Integer.parseInt(sizeTextField3.getText());
            if (sizeval > 32768 || sizeval < 64) {
                JOptionPane.showMessageDialog(this, "Packet size should be in the range 64 to 32768 Bytes");
                sizeTextField3.setText("32768");
                return;
            }

        } catch (Exception e) {// alert for invalid chars
            JOptionPane.showMessageDialog(this, "Packet size must be an integer");
            sizeTextField3.setText("32768");
            return;
        }
        if (!CheckerChcekBox3.isSelected() && !GeneratorCheckbox3.isSelected()) {
            JOptionPane.showMessageDialog(this, "Please select atleast one option in Test Control.");
            return;
        }

        if (jbuttonEngStart3.getText().equalsIgnoreCase("Start")) {
            jbuttonEngStart3.setText("Stop");
            if (CheckerChcekBox3.isSelected()) {
                testMode = DriverInfo.CHECKER;
            }
            if (GeneratorCheckbox3.isSelected()) {
                testMode = DriverInfo.GENERATOR;
            }
            if (CheckerChcekBox3.isSelected() && GeneratorCheckbox3.isSelected()) {
                testMode = DriverInfo.CHECKER_GEN;
            }

            int size = Integer.parseInt(sizeTextField3.getText());
            di.startTest(0, testMode, size);
            testStarted = true;
            // Disabling all components
            CheckerChcekBox3.setEnabled(false);
            GeneratorCheckbox3.setEnabled(false);
            sizeTextField3.setEditable(false);
            messageLog1.append(">> Test Started\n");

        } else {
            testStarted = false;
            jbuttonEngStart3.setText("Start");
            CheckerChcekBox3.setEnabled(true);
            GeneratorCheckbox3.setEnabled(true);
            sizeTextField3.setEditable(true);
            // reset data.
            axiTxTextField3.setText("0.000");
            axiRxTextField3.setText("0.000");
//            ddrRxTextField.setText("0.000");
//            ddrTxTextField.setText("0.000");

            pcieTxTextField3.setText("0.000");
            pcieRxTextField3.setText("0.000");

            //timer.cancel();
            chartBottom.reset();
            chartTop.reset();
            int size = Integer.parseInt(sizeTextField3.getText());
            di.stopTest(0, testMode, size);
            messageLog1.append(">> Test Stopped\n");
        }

    }//GEN-LAST:event_jbuttonEngStart3ActionPerformed

    private void browseButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_browseButtonActionPerformed
        // TODO add your handling code here:
        JFileChooser filechoser = new JFileChooser();
        if (filechoser.showOpenDialog(new JFrame()) == JFileChooser.APPROVE_OPTION) {
            pathFied.setText(filechoser.getSelectedFile().getPath());
        }

    }//GEN-LAST:event_browseButtonActionPerformed

    private void videoplayButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_videoplayButtonActionPerformed
        // TODO add your handling code here:
        if (videoplayButton.getText().equalsIgnoreCase("Start")) {
            if (screenMode == 2 && ddrledState == 0) {// check for gencheck with card ddr.
                JOptionPane.showMessageDialog(this, "DDR4 not calibrated. Could not start the test.");
                return;
            }
            // conditional check for min and max
            if (pathFied.getText().length() == 0) {
                Object[] options1 = {"Ok"};
                int s = JOptionPane.showOptionDialog(null, "Please choose Video file path", " ",
                        JOptionPane.CLOSED_OPTION, JOptionPane.QUESTION_MESSAGE,
                        null, options1, null);
                return;
            }
            if (Integer.parseInt(mincoeff.getValue().toString()) > Integer.parseInt(maxcoeff.getValue().toString())) {
                Object[] options1 = {"Ok"};
                int s = JOptionPane.showOptionDialog(null, "Min Threshold should always be less than Max Threshold", " ",
                        JOptionPane.CLOSED_OPTION, JOptionPane.QUESTION_MESSAGE,
                        null, options1, null);
                return;
            }
            messageLog2.append(">> Test Started\n");
            videoPauseButton.setEnabled(true);
            videoPauseButton.setText("Pause");
            videoplayButton.setText("Stop");
            pathFied.setEnabled(false);
            browseButton.setEnabled(false);
//            mincoeff.setEnabled(false);
//            maxcoeff.setEnabled(false);
//            invertcheckbox.setEnabled(false);
            testStarted = true;

            di.startVideoTest(0, 7, Integer.parseInt(mincoeff.getValue().toString()), Integer.parseInt(maxcoeff.getValue().toString()), invertcheckbox.isSelected() ? 1 : 0, 7680);
            BGWorker worker = new BGWorker("./util/run_all_vlc.sh" + " start " + pathFied.getText());
            worker.execute();
            try {
                Thread.sleep(500);
            } catch (InterruptedException ex) {
                Logger.getLogger(MainScreen.class.getName()).log(Level.SEVERE, null, ex);
            }

        } else {
            testStarted = false;
            videoplayButton.setText("Start");
            videoPauseButton.setEnabled(false);
            BGWorker worker = new BGWorker("./kill_vlc.sh");
            worker.execute();

            pathFied.setEnabled(true);
            browseButton.setEnabled(true);
//            mincoeff.setEnabled(true);
//            maxcoeff.setEnabled(true);
//            invertcheckbox.setEnabled(true);

            di.stopVideoTest(0, 7, 7680);

            axiTxTextField4.setText("0.000");
            axiRxTextField4.setText("0.000");
//            ddrRxTextField.setText("0.000");
//            ddrTxTextField.setText("0.000");

            pcieTxTextField4.setText("0.000");
            pcieRxTextField4.setText("0.000");
            messageLog2.append(">> Test Stopped\n");
            try {
                Thread.sleep(15000);
            } catch (InterruptedException ex) {
                Logger.getLogger(MainScreen.class.getName()).log(Level.SEVERE, null, ex);
            }
        }

    }//GEN-LAST:event_videoplayButtonActionPerformed

    private void videoPauseButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_videoPauseButtonActionPerformed
        // TODO add your handling code here:
        if (videoPauseButton.getText().equalsIgnoreCase("Pause")) {
            videoPauseButton.setText("Resume");
            BGWorker worker = new BGWorker("./util/run_vlc.sh" + " pause " + pathFied.getText());
            worker.execute();
        } else {
            videoPauseButton.setText("Pause");
            BGWorker worker = new BGWorker("./util/run_vlc.sh" + " pause " + pathFied.getText());
            worker.execute();
        }
        try {
            Thread.sleep(500);
        } catch (InterruptedException ex) {
            Logger.getLogger(MainScreen.class.getName()).log(Level.SEVERE, null, ex);
        }

    }//GEN-LAST:event_videoPauseButtonActionPerformed

    private void invertcheckboxActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_invertcheckboxActionPerformed
        // TODO add your handling code here:
        if (testStarted == true) {
            di.startVideoTest(0, 7, Integer.parseInt(mincoeff.getValue().toString()), Integer.parseInt(maxcoeff.getValue().toString()), invertcheckbox.isSelected() ? 1 : 0, 7680);
        }
    }//GEN-LAST:event_invertcheckboxActionPerformed

    private void maxcoeffStateChanged(javax.swing.event.ChangeEvent evt) {//GEN-FIRST:event_maxcoeffStateChanged
        // TODO add your handling code here:
        if (testStarted == true) {
            SpinnerNumberModel sp = (SpinnerNumberModel) mincoeff.getModel();
            sp.setMaximum(Integer.parseInt(maxcoeff.getValue().toString()));
            mincoeff.setModel(sp);
            di.startVideoTest(0, 7, Integer.parseInt(mincoeff.getValue().toString()), Integer.parseInt(maxcoeff.getValue().toString()), invertcheckbox.isSelected() ? 1 : 0, 7680);
        }
    }//GEN-LAST:event_maxcoeffStateChanged

    private void mincoeffStateChanged(javax.swing.event.ChangeEvent evt) {//GEN-FIRST:event_mincoeffStateChanged
        // TODO add your handling code here:
        if (testStarted == true) {
            SpinnerNumberModel sp = (SpinnerNumberModel) maxcoeff.getModel();
            sp.setMinimum(Integer.parseInt(mincoeff.getValue().toString()));

            maxcoeff.setModel(sp);
            di.startVideoTest(0, 7, Integer.parseInt(mincoeff.getValue().toString()), Integer.parseInt(maxcoeff.getValue().toString()), invertcheckbox.isSelected() ? 1 : 0, 7680);
        }
    }//GEN-LAST:event_mincoeffStateChanged

    /**
     * @param args the command line arguments
     */
    /* public static void main(String args[]) {
       
     java.awt.EventQueue.invokeLater(new Runnable() {
     public void run() {
     ms = getInstance();
     ms.setVisible(true);
     ms.loadVideo();
     }
     });
     }*/
    public void removeStatsPanel() {
        tabbedPanel.remove(statusPanel);
    }

    public void loadVideo() {
        ControlPanel.add(VideoPanel);
        VideoPanel.setSize(ControlPanel.getSize());
        ControlPanel.repaint();
        ControlPanel.revalidate();

        maxcoeff.setModel(new SpinnerNumberModel(200, 0, 255, 1));
        mincoeff.setModel(new SpinnerNumberModel(100, 0, 255, 1));

    }
    PowerChart chart1;

    public void loadAllGraphs() {

        JPanel PowerGraphPanel = createPanelForGraph(PowerPanel);
        chart1 = new PowerChart("Power (W)", PowerGraphPanel.getBackground());

        ChartPanel dialPanel;
        dialPanel = chart1.getChart("");
        dialPanel.setPreferredSize(new Dimension(300, 100));
        PowerGraphPanel.add(dialPanel);

        PowerPanel.add(PowerGraphPanel);

        // loading power graph and running timer
        if (screenMode == 3 || screenMode == 4) {
            String[] labels0 = {"S2C PCIe", "AXI Transmit Data Path 0", "AXI Transmit Data Path 1"};
            String[] labels2 = {"C2S PCIe", "AXI Receive Data Path 0", "AXI Receive Data Path 1"};
            chartTopEth = new BarChartsEth("", "", PowerGraphPanel.getBackground(), labels0);

            JPanel PowerGraphPanel2 = createPanelForGraph(topChartperfpanel);
            PowerGraphPanel2.add(chartTopEth.getChart(""));
            topChartperfpanel.add(PowerGraphPanel2);

            chartBottomEth = new BarChartsEth("", "", PowerGraphPanel.getBackground(), labels2);

            JPanel PowerGraphPanel3 = createPanelForGraph(topChartperfpanel);
            PowerGraphPanel3.add(chartBottomEth.getChart(""));
            bottomChartperfpanel.add(PowerGraphPanel3);

            // upper bounds for graphs
            if (screenMode == 3 || screenMode == 4 || screenMode == 7) {
                chartTopEth.upperBounds(35);
                chartBottomEth.upperBounds(35);
            }
        } else {
            if (screenMode == 7) {
                String[] labels0 = {"S2C PCIe", "S2C AXI"};
                String[] labels2 = {"C2S PCIe", "C2S AXI"};
                chartTop = new BarCharts("", "", PowerGraphPanel.getBackground(), labels0);

                JPanel PowerGraphPanel2 = createPanelForGraph(topChartperfpanel);
                PowerGraphPanel2.add(chartTop.getChart(""));
                topChartperfpanel.add(PowerGraphPanel2);

                chartBottom = new BarCharts("", "", PowerGraphPanel.getBackground(), labels2);

                JPanel PowerGraphPanel3 = createPanelForGraph(topChartperfpanel);
                PowerGraphPanel3.add(chartBottom.getChart(""));
                bottomChartperfpanel.add(PowerGraphPanel3);

                chartTop.upperBounds(32);
                chartBottom.upperBounds(32);
            } else {
                String[] labels0 = {"S2C PCIe", "DDR Writes"};
                String[] labels2 = {"C2S PCIe", "DDR Reads"};
                chartTop = new BarCharts("", "", PowerGraphPanel.getBackground(), labels0);

                JPanel PowerGraphPanel2 = createPanelForGraph(topChartperfpanel);
                PowerGraphPanel2.add(chartTop.getChart(""));
                topChartperfpanel.add(PowerGraphPanel2);

                chartBottom = new BarCharts("", "", PowerGraphPanel.getBackground(), labels2);

                JPanel PowerGraphPanel3 = createPanelForGraph(topChartperfpanel);
                PowerGraphPanel3.add(chartBottom.getChart(""));
                bottomChartperfpanel.add(PowerGraphPanel3);
            }
        }
        if (screenMode == 2) {

            chartTop.upperBounds(4);
            chartBottom.upperBounds(4);
        }
        updateStats();

    }

    public JPanel createPanelForGraph(JPanel panel) {
        // dimensions
        Dimension dmsns = new Dimension(panel.getWidth(), panel.getHeight());
        JPanel dmaStatsPanel = new JPanel();
        dmaStatsPanel.setLayout(new BoxLayout(dmaStatsPanel, BoxLayout.Y_AXIS));
        dmaStatsPanel.setSize(dmsns);
        return dmaStatsPanel;
    }

    public void loadDataPath() {
        // changing the gui according to the screen mode for Ethernet.
        if (screenMode == 3) {
            // Raw ethernet mode
            loopbackCheckBox1.setVisible(false);
            CheckerChcekBox1.setVisible(false);
            GeneratorCheckbox1.setVisible(false);
            loopbackCheckBox2.setVisible(false);
            CheckerChcekBox2.setVisible(false);
            GeneratorCheckbox2.setVisible(false);

            // adjusting the panel.
            ControlPanel.add(DataPathPanelForOneEC);
            DataPathPanelForOneEC.setSize(ControlPanel.getSize());
            ControlPanel.repaint();
            ControlPanel.revalidate();

        } else if (screenMode == 7) {
            // Gen chk mode
            datapathpanel1.setVisible(false);
//            jPanel5.setVisible(false);
//            jPanel30.setVisible(false);
            DataPathPanelForOneEC.add(messagelogPanel);
            messagelogPanel.setLocation(new Point(0, 320));
            messagelogPanel.setSize(new Dimension(520, 227));

            DataPathPanelForOneEC.revalidate();
            DataPathPanelForOneEC.repaint();

            // adjusting the panel.
            ControlPanel.add(DataPathPanelForOneEC_GC);
            DataPathPanelForOneEC_GC.setSize(ControlPanel.getSize());
            ControlPanel.repaint();
            ControlPanel.revalidate();
        } else {
            // application mode.
            loopbackCheckBox1.setVisible(false);
            CheckerChcekBox1.setVisible(false);
            GeneratorCheckbox1.setVisible(false);
            loopbackCheckBox2.setVisible(false);
            CheckerChcekBox2.setVisible(false);
            GeneratorCheckbox2.setVisible(false);

            sizeTextField1.setEditable(false);
            jbuttonEngStart1.setEnabled(false);
            sizeTextField2.setEditable(false);
            jbuttonEngStart2.setEnabled(false);

            // adjusting the panel.
            ControlPanel.add(DataPathPanelForOneEC);
            DataPathPanelForOneEC.setSize(ControlPanel.getSize());
            ControlPanel.repaint();
            ControlPanel.revalidate();
        }
        // changing names of the panel
        axilblread0.setText("AXI Receive (in Gbps):");
        axilblwrite0.setText("AXI Transmit (in Gbps):");
        axilblread1.setText("AXI Receive (in Gbps):");
        axilblwrite1.setText("AXI Transmit (in Gbps):");
        ((javax.swing.border.TitledBorder) axiTruputpanle0.getBorder()).setTitle("AXI Stream Throughput");
        ((javax.swing.border.TitledBorder) axiTruputpanle1.getBorder()).setTitle("AXI Stream Throughput");

    }

    public void loadDataPathForoneDP() {
        ControlPanel.add(DataPathPanelForOneDP);
        DataPathPanelForOneDP.setSize(ControlPanel.getSize());
        ControlPanel.repaint();
        ControlPanel.revalidate();
//        ddr4panel.setVisible(false);
    }

    public void loadDataPathForoneDPRDWDP() {
        ControlPanel.add(DataPathPanelForOneDP);
        DataPathPanelForOneDP.setSize(ControlPanel.getSize());
        ControlPanel.repaint();
        ControlPanel.revalidate();
    }

    public void loadReadWriteCmd() {
        ControlPanel.add(ReadWritePanel);
        ReadWritePanel.setSize(ControlPanel.getSize());
        ControlPanel.repaint();
        ControlPanel.revalidate();

    }

    public static MainScreen getInstance() {
//        if (ms == null) 
        {
            ms = new MainScreen();
        }
        return ms;
    }

    public void makeDMAData() {

        int ret = di.get_TRNStats();
        TRNStats trnStats = di.getTRNStats();
        ret = di.get_EngineState();
        EngState[] estate = di.getEngState();

        if (testStarted) {
            if (incValue > 1) {
                if (screenMode == 7) {
                    pcieTxTextField3.setText(String.format("%2.3f", trnStats.LTX));
                    pcieRxTextField3.setText(String.format("%2.3f", trnStats.LRX));

                    //  change here for the integration.
                    axiTxTextField3.setText(String.format("%2.3f", trnStats.WBC_APM));
                    axiRxTextField3.setText(String.format("%2.3f", trnStats.RBC_APM));

                    // DMA data
//        ddrTxTextField.setText(String.format("%2.3f", trnStats.WBC_DDR));
//        ddrRxTextField.setText(String.format("%2.3f", trnStats.RBC_DDR));
                    // error log
                    for (int i = 0; i < estate.length; i++) {
                        if (estate[0].srcErrs != 0) {
                            messageLog1.append("Error :: Source error occured on engine " + i + "\n");
                        }
                        if (estate[0].destErrs != 0) {
                            messageLog1.append("Error :: Destination error occured on engine " + i + "\n");
                        }
                        if (estate[0].internalErrs != 0) {
                            messageLog1.append("Error :: Internal error occured on engine " + i + "\n");
                        }

                    }
                } else if (screenMode == 2) {// accelerator mode from axi mm data plane
                    pcieTxTextField4.setText(String.format("%2.3f", trnStats.LTX));
                    pcieRxTextField4.setText(String.format("%2.3f", trnStats.LRX));

                    //  change here for the integration.
                    axiTxTextField4.setText(String.format("%2.3f", trnStats.WBC_APM));
                    axiRxTextField4.setText(String.format("%2.3f", trnStats.RBC_APM));

                    // DMA data
//        ddrTxTextField.setText(String.format("%2.3f", trnStats.WBC_DDR));
//        ddrRxTextField.setText(String.format("%2.3f", trnStats.RBC_DDR));
                    // error log
                    for (int i = 0; i < estate.length; i++) {
                        if (estate[0].srcErrs != 0) {
                            messageLog2.append("Error :: Source error occured on engine " + i + "\n");
                        }
                        if (estate[0].destErrs != 0) {
                            messageLog2.append("Error :: Destination error occured on engine " + i + "\n");
                        }
                        if (estate[0].internalErrs != 0) {
                            messageLog2.append("Error :: Internal error occured on engine " + i + "\n");
                        }

                    }

                } else {
                    pcieTxTextField1.setText(String.format("%2.3f", trnStats.LTX));
                    pcieRxTextField1.setText(String.format("%2.3f", trnStats.LRX));

                    //  change here for the integration.
                    axiTxTextField.setText(String.format("%2.3f", trnStats.WBC_APM));
                    axiRxTextField.setText(String.format("%2.3f", trnStats.RBC_APM));

                    // DMA data
//        ddrTxTextField.setText(String.format("%2.3f", trnStats.WBC_DDR));
//        ddrRxTextField.setText(String.format("%2.3f", trnStats.RBC_DDR));
                    // error log
                    for (int i = 0; i < estate.length; i++) {
                        if (estate[0].srcErrs != 0) {
                            messageLog.append("Error :: Source error occured on engine " + i + "\n");
                        }
                        if (estate[0].destErrs != 0) {
                            messageLog.append("Error :: Destination error occured on engine " + i + "\n");
                        }
                        if (estate[0].internalErrs != 0) {
                            messageLog.append("Error :: Internal error occured on engine " + i + "\n");
                        }

                    }
                }

                // update charts here.
                chartTop.updateChart(trnStats.LRX, trnStats.WBC_APM);
                chartBottom.updateChart(trnStats.LTX, trnStats.RBC_APM);
            }
            incValue++;
            if (incValue > 10000) {
                incValue = 4;
            }
        } else {
            incValue = 0;
        }
        double wbcApmDP0 = 0, rbcApmDP0 = 0, wbcApmDP1 = 0, rbcApmDP1 = 0;
//        if (ethTestStarted0) {
//            //  change here for the integration.
//            axiTxTextField1.setText(String.format("%2.3f", trnStats.WBC_APM));
//            axiRxTextField1.setText(String.format("%2.3f", trnStats.RBC_APM));
//            wbcApmDP0 = trnStats.WBC_APM;
//            rbcApmDP0 = trnStats.RBC_APM;
//
//        }
//        if (ethTestStarted1) {
//            axiTxTextField2.setText(String.format("%2.3f", trnStats.WBC_APM1));
//            axiRxTextField2.setText(String.format("%2.3f", trnStats.RBC_APM1));
//            wbcApmDP1 = trnStats.WBC_APM;
//            rbcApmDP1 = trnStats.RBC_APM;
//        }
        if (ethTestStarted0 || ethTestStarted1 || screenMode == 4) {
            if (ethincVal > 1) {
                axiTxTextField1.setText(String.format("%2.3f", trnStats.WBC_APM));
                axiRxTextField1.setText(String.format("%2.3f", trnStats.RBC_APM));
                wbcApmDP0 = trnStats.WBC_APM;
                rbcApmDP0 = trnStats.RBC_APM;

                axiTxTextField2.setText(String.format("%2.3f", trnStats.WBC_APM1));
                axiRxTextField2.setText(String.format("%2.3f", trnStats.RBC_APM1));
                wbcApmDP1 = trnStats.WBC_APM1;
                rbcApmDP1 = trnStats.RBC_APM1;
                // update chart
                pcieTxTextField2.setText(String.format("%2.3f", trnStats.LTX));
                pcieRxTextField2.setText(String.format("%2.3f", trnStats.LRX));

                // update charts here.
                chartTopEth.updateChart(trnStats.LRX, wbcApmDP0, wbcApmDP1);
                chartBottomEth.updateChart(trnStats.LTX, rbcApmDP0, rbcApmDP1);
            }
            ethincVal++;
            if (ethincVal > 10000) {
                ethincVal = 4;
            }

        } else {
            ethincVal = 0;

        }
        if (screenMode == 4 || screenMode == 3) {
            int rets = di.get_LedStats();
            LedStats lstats = di.getLedStats();

            if (lstats.phy0 == 0) {
                phy0icon.setIcon(new ImageIcon(getClass().getResource("/com/xilinx/ultrascale/gui/gray.png")));
            } else {
                phy0icon.setIcon(new ImageIcon(getClass().getResource("/com/xilinx/ultrascale/gui/green.png")));

            }
            if (lstats.phy1 == 0) {
                phy1icon.setIcon(new ImageIcon(getClass().getResource("/com/xilinx/ultrascale/gui/gray.png")));
            } else {
                phy1icon.setIcon(new ImageIcon(getClass().getResource("/com/xilinx/ultrascale/gui/green.png")));

            }
        }
    }
    int incValue = 0;
    int ethincVal = 0;

    public void updatePowerAndTemp() {
        if (Develop.production == 1) {
            int ret = di.get_PowerStats();

            PowerStats ps = di.getPowerStats();
            MajorTempLabel3.setIcon(ledicons[ps.die_temp / 100]);
            int tempVal = ps.die_temp;
            if (ps.die_temp >= 100) {
                tempVal -= 100;
            }
            MajorTempLabel.setIcon(ledicons[tempVal / 10]);
            MinorTempLabel.setIcon(ledicons[tempVal % 10]);
            TempMeasureLabel.setText("" + "°C");

            chart1.updateChart((double) ps.vccint / 1000.0,(double) ps.mgtvcc / 1000.0, (double) ps.vccaux / 1000.0,
                     (double) ps.vccbram / 1000.0);
        } else { // dummy values
            MajorTempLabel.setIcon(ledicons[32 / 10]);
            MinorTempLabel.setIcon(ledicons[32 % 10]);
            TempMeasureLabel.setText("" + "°C");

            chart1.updateChart((double) 1, (double) 2, (double) 1.5, (double) 2.5);
        }
    }
    static MainScreen ms;
    DriverInfo di;
    MyTableModel tblModel;
    MyTableModel pciemodel;
    MyTableModel hostCredits;
    MyTableModel barDumpModel;
    String[] dmaColumnNames0 = {"Parameters", "S2C", "C2S"};
    String[] pcieColumnNames = {"Type", "Value"};
    String[] bardumpNames = {"Address", "Value", "Value", "Value", "Value"};
    Object[][] bardumpDummy = {
        {"", "", "", "", ""},
        {"", "", "", "", ""},
        {"", "", "", "", ""},
        {"", "", "", "", ""},
        {"", "", "", "", ""},
        {"", "", "", "", ""},
        {"", "", "", "", ""},
        {"", "", "", "", ""},
        {"", "", "", "", ""},
        {"", "", "", "", ""},
        {"", "", "", "", ""},
        {"", "", "", "", ""},
        {"", "", "", "", ""},
        {"", "", "", "", ""}
    };
    Object[][] dummydata = {
        {"DMA", 0, 0},
        {"srcSGLBDs", 0, 0},
        {"destSGLBDs", 0, 0},
        {"srcStatsBD", 0, 0},
        {"destStatsBD", 0, 0},
        {"srcErrs", 0, 0},
        {"destErrs", 0, 0},
        {"internalErrs", 0, 0}
    };
    String[] pcieEndptClm = {"Type", "Value"};
    Object[][] dataForPCIEDummy = {
        {"Link State", "Up"},
        {"", ""},
        {"Link Speed", "5 Gbps"},
        {"Link Width", "x8"},
        {"", ""},
        {"Vendor ID", "0x10ee"},
        {"Device ID", "0x7082"},
        {"", ""},
        {"MPS(Bytes)", "128"},
        {"MRPS(Bytes)", "512"}
    };
    String[] hostPcie = {"Type", "Value"};
    Object[][] hostPcieDummy = {
        {"Bar", "2"},
        {"Address range", ""},
        {"size", "5 Gbps"},
        {"", ""},
        {"Bar", "4"},
        {"Address range", ""},
        {"size", "5 Gbps"},
        {"", ""},
        {"Bar", "6"},
        {"Address range", ""},
        {"size", "5 Gbps"},};
//     MyTableModel tblModel1;
//    MyTableModel pciemodel;
//    MyTableModel hostCredits;
//    String[] dmaColumnNames1 = {"Parameters", "Transmit(S2C0)", "Receive(C2S0)"};
//    String[] hostColumnNames = {"Type", "Value"};
//    Object[][] dummydata = {
//        {"srcSGLBDs", 0, 0},
//        {"destSGLBDs", 0, 0},
//        {"srcStatsBD", 0, 0},
//        {"destStatsBD", 0, 0},
//        {"Buffers", 0, 0},
//        {"srcErrs", 0, 0},
//        {"destErrs", 0, 0},
//        {"internalErrs", 0, 0}
//    };
//    String[] pcieEndptClm = {"Type", "Value"};
//    Object[][] dataForHostDummy = {
//        {"Link State", "Up"},
//        {"", ""},
//        {"Link Speed", "5 Gbps"},
//        {"Link Width", "x8"},
//        {"", ""},
//        {"Vendor ID", "0x10ee"},
//        {"Device ID", "0x7082"},
//        {"", ""},
//        {"MPS(Bytes)", "128"},
//        {"MRPS(Bytes)", "512"}           
    boolean testStarted;
    boolean ethTestStarted0;
    boolean ethTestStarted1;
    int testMode;
    int eth0TestMode;
    int eth1TestMode;
    int maxSize;
    ImageIcon[] ledicons = new ImageIcon[10];
    BarCharts chartTop;
    BarCharts chartBottom;
    BarChartsEth chartTopEth;
    BarChartsEth chartBottomEth;
    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JTextField AddressTextField;
    private javax.swing.JPanel BlockDiagramPanel;
    private javax.swing.JCheckBox CheckerChcekBox;
    private javax.swing.JCheckBox CheckerChcekBox1;
    private javax.swing.JCheckBox CheckerChcekBox2;
    private javax.swing.JCheckBox CheckerChcekBox3;
    private javax.swing.JPanel ControlPanel;
    private javax.swing.JLabel DDR4label;
    private javax.swing.JPanel DataPathPanel;
    private javax.swing.JPanel DataPathPanelForOneDP;
    private javax.swing.JPanel DataPathPanelForOneEC;
    private javax.swing.JPanel DataPathPanelForOneEC_GC;
    private javax.swing.JPanel DyPanel;
    private javax.swing.JCheckBox GeneratorCheckbox;
    private javax.swing.JCheckBox GeneratorCheckbox1;
    private javax.swing.JCheckBox GeneratorCheckbox2;
    private javax.swing.JCheckBox GeneratorCheckbox3;
    private javax.swing.JPanel HeadingPanel;
    private javax.swing.JLabel MajorTempLabel;
    private javax.swing.JLabel MajorTempLabel1;
    private javax.swing.JLabel MajorTempLabel2;
    private javax.swing.JLabel MajorTempLabel3;
    private javax.swing.JLabel MinorTempLabel;
    private javax.swing.JLabel MinorTempLabel1;
    private javax.swing.JPanel PcieEndStatuspanel;
    private javax.swing.JPanel PerformancePlotTab;
    private javax.swing.JPanel PowerPanel;
    private javax.swing.JPanel ReadPanel;
    private javax.swing.JPanel ReadWritePanel;
    private javax.swing.JLabel TempMeasureLabel;
    private javax.swing.JLabel TempMeasureLabel1;
    private javax.swing.JPanel VideoPanel;
    private javax.swing.JPanel WritePanel;
    private javax.swing.JTextField axiRxTextField;
    private javax.swing.JTextField axiRxTextField1;
    private javax.swing.JTextField axiRxTextField2;
    private javax.swing.JTextField axiRxTextField3;
    private javax.swing.JTextField axiRxTextField4;
    private javax.swing.JPanel axiTruputpanle0;
    private javax.swing.JPanel axiTruputpanle1;
    private javax.swing.JTextField axiTxTextField;
    private javax.swing.JTextField axiTxTextField1;
    private javax.swing.JTextField axiTxTextField2;
    private javax.swing.JTextField axiTxTextField3;
    private javax.swing.JTextField axiTxTextField4;
    private javax.swing.JLabel axilblread0;
    private javax.swing.JLabel axilblread1;
    private javax.swing.JLabel axilblwrite0;
    private javax.swing.JLabel axilblwrite1;
    private javax.swing.JComboBox barComboBoxTop;
    private javax.swing.JComboBox barComboBoxTop1;
    private javax.swing.JComboBox barComboBoxbottom;
    private javax.swing.JTable bardump;
    private javax.swing.JButton blockdiagrambutton;
    private javax.swing.JLabel blockdiagramlbl;
    private javax.swing.JPanel bottomChartperfpanel;
    private javax.swing.JButton browseButton;
    private javax.swing.JTextField dataTextfield;
    private javax.swing.JTextField dataTextfield1;
    private javax.swing.JPanel datapathpanel1;
    private javax.swing.JLabel ddricon;
    private javax.swing.JPanel ddrpanel;
    private javax.swing.JTextField dmaRxTextField1;
    private javax.swing.JTextField dmaTxTextField1;
    private javax.swing.JButton executeBarButton;
    private javax.swing.JButton executeRWButton;
    private javax.swing.JButton executeRWButton1;
    private javax.swing.JLabel headinglable;
    private javax.swing.JPanel hexdumppanel;
    private javax.swing.JPanel hostCreditsPanel;
    private javax.swing.JTable hostsysmontable;
    private javax.swing.JCheckBox invertcheckbox;
    private javax.swing.JButton jButton2;
    private javax.swing.JButton jButton3;
    private javax.swing.JCheckBox jCheckBox1;
    private javax.swing.JCheckBox jCheckBox2;
    private javax.swing.JCheckBox jCheckBox3;
    private javax.swing.JCheckBox jCheckBox4;
    private javax.swing.JCheckBox jCheckBox5;
    private javax.swing.JCheckBox jCheckBox6;
    private javax.swing.JLabel jLabel1;
    private javax.swing.JLabel jLabel10;
    private javax.swing.JLabel jLabel11;
    private javax.swing.JLabel jLabel12;
    private javax.swing.JLabel jLabel13;
    private javax.swing.JLabel jLabel14;
    private javax.swing.JLabel jLabel15;
    private javax.swing.JLabel jLabel16;
    private javax.swing.JLabel jLabel17;
    private javax.swing.JLabel jLabel18;
    private javax.swing.JLabel jLabel19;
    private javax.swing.JLabel jLabel2;
    private javax.swing.JLabel jLabel20;
    private javax.swing.JLabel jLabel21;
    private javax.swing.JLabel jLabel22;
    private javax.swing.JLabel jLabel23;
    private javax.swing.JLabel jLabel24;
    private javax.swing.JLabel jLabel25;
    private javax.swing.JLabel jLabel26;
    private javax.swing.JLabel jLabel27;
    private javax.swing.JLabel jLabel28;
    private javax.swing.JLabel jLabel29;
    private javax.swing.JLabel jLabel3;
    private javax.swing.JLabel jLabel30;
    private javax.swing.JLabel jLabel31;
    private javax.swing.JLabel jLabel32;
    private javax.swing.JLabel jLabel33;
    private javax.swing.JLabel jLabel34;
    private javax.swing.JLabel jLabel35;
    private javax.swing.JLabel jLabel36;
    private javax.swing.JLabel jLabel37;
    private javax.swing.JLabel jLabel38;
    private javax.swing.JLabel jLabel39;
    private javax.swing.JLabel jLabel4;
    private javax.swing.JLabel jLabel5;
    private javax.swing.JLabel jLabel6;
    private javax.swing.JLabel jLabel7;
    private javax.swing.JLabel jLabel8;
    private javax.swing.JLabel jLabel9;
    private javax.swing.JPanel jPanel1;
    private javax.swing.JPanel jPanel15;
    private javax.swing.JPanel jPanel16;
    private javax.swing.JPanel jPanel17;
    private javax.swing.JPanel jPanel2;
    private javax.swing.JPanel jPanel25;
    private javax.swing.JPanel jPanel26;
    private javax.swing.JPanel jPanel27;
    private javax.swing.JPanel jPanel28;
    private javax.swing.JPanel jPanel29;
    private javax.swing.JPanel jPanel3;
    private javax.swing.JPanel jPanel30;
    private javax.swing.JPanel jPanel31;
    private javax.swing.JPanel jPanel32;
    private javax.swing.JPanel jPanel33;
    private javax.swing.JPanel jPanel34;
    private javax.swing.JPanel jPanel35;
    private javax.swing.JPanel jPanel36;
    private javax.swing.JPanel jPanel4;
    private javax.swing.JPanel jPanel5;
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JScrollPane jScrollPane2;
    private javax.swing.JScrollPane jScrollPane3;
    private javax.swing.JScrollPane jScrollPane4;
    private javax.swing.JScrollPane jScrollPane5;
    private javax.swing.JScrollPane jScrollPane6;
    private javax.swing.JScrollPane jScrollPane7;
    private javax.swing.JScrollPane jScrollPane8;
    private javax.swing.JTable jTable3;
    private javax.swing.JTable jTable4;
    private javax.swing.JTextField jTextField1;
    private javax.swing.JTextField jTextField2;
    private javax.swing.JTextField jTextField3;
    private javax.swing.JTextField jTextField4;
    private javax.swing.JButton jbuttonEngStart;
    private javax.swing.JButton jbuttonEngStart1;
    private javax.swing.JButton jbuttonEngStart2;
    private javax.swing.JButton jbuttonEngStart3;
    private javax.swing.JPanel ledPanel;
    private javax.swing.JTextArea logArea;
    private javax.swing.JScrollPane logscrollpanel;
    private javax.swing.JCheckBox loopbackCheckBox1;
    private javax.swing.JCheckBox loopbackCheckBox2;
    private javax.swing.JSpinner maxcoeff;
    private javax.swing.JTextArea messageLog;
    private javax.swing.JTextArea messageLog1;
    private javax.swing.JTextArea messageLog2;
    private javax.swing.JPanel messagelogPanel;
    private javax.swing.JPanel messagelogPanel1;
    private javax.swing.JPanel messagelogPanel2;
    private javax.swing.JSpinner mincoeff;
    private javax.swing.JTextField offsetTextField;
    private javax.swing.JTextField offsetTextField1;
    private javax.swing.JTextField pathFied;
    private javax.swing.JTextField pcieRxTextField1;
    private javax.swing.JTextField pcieRxTextField2;
    private javax.swing.JTextField pcieRxTextField3;
    private javax.swing.JTextField pcieRxTextField4;
    private javax.swing.JTable pcieSysmontable;
    private javax.swing.JTextField pcieTxTextField1;
    private javax.swing.JTextField pcieTxTextField2;
    private javax.swing.JTextField pcieTxTextField3;
    private javax.swing.JTextField pcieTxTextField4;
    private javax.swing.JLabel phty1label;
    private javax.swing.JLabel phy0icon;
    private javax.swing.JLabel phy0label;
    private javax.swing.JPanel phy0panel;
    private javax.swing.JLabel phy1icon;
    private javax.swing.JPanel phy1panel;
    private javax.swing.JTextField sizeControlTextField;
    private javax.swing.JTextField sizeTextField;
    private javax.swing.JTextField sizeTextField1;
    private javax.swing.JTextField sizeTextField2;
    private javax.swing.JTextField sizeTextField3;
    private javax.swing.JPanel statusPanel;
    private javax.swing.JPanel sysmonpanel;
    private javax.swing.JTabbedPane tabbedPanel;
    private javax.swing.JPanel tabpanel;
    private javax.swing.JPanel tempholdPanel;
    private javax.swing.JPanel tempvaluePanel;
    private javax.swing.JPanel tempvaluePanel1;
    private javax.swing.JPanel topChartperfpanel;
    private javax.swing.JPanel topVidpanel;
    private javax.swing.JButton videoPauseButton;
    private javax.swing.JButton videoplayButton;
    // End of variables declaration//GEN-END:variables

    void updategrapshforvideo() {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }
}
