package com.xilinx.ultrascale.gui;

import javax.swing.JRadioButton;
import javax.swing.UIManager;
import com.xilinx.ultrascale.laf.NimbusLookAndFeel;
import javax.swing.*;
import java.io.*;
import java.awt.Dialog.ModalityType;
import java.awt.*;
import java.rmi.AlreadyBoundException;
import javax.swing.JOptionPane;
/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author Mobigesture
 */
public class LandingPage extends javax.swing.JFrame {

    /**
     * Creates new form LandingPage
     */
    public LandingPage() {
        initComponents();
        this.setLocationRelativeTo(null);
        jLabel3.setText("Getting Device ID...");
        // execute shell command to get the Device name
        try {
            Runtime runtime = Runtime.getRuntime();
            String cmd = "lspci | grep Xilinx 2>&1";
            Process process = runtime.exec(new String[]{"/bin/bash", "-c", cmd});
            int exitValue = process.waitFor();
            InputStream is = process.getInputStream();
            BufferedReader br = new BufferedReader(new InputStreamReader(is));
            String line;
            String res = "";
            while ((line = br.readLine()) != null) {
                res += line;
            }
            GENCHKRadioButton.setVisible(false);
            //System.out.println(res);
            is.close();
            // selection of mode based on the obtained lspci command.
            if (res.length() > 2 && (res.contains("8083") || res.contains("8043"))) {
                acceleratorRadioButton.setSelected(true);
                acceleratorRadioButton.setEnabled(true);
                EthernetRadioButton.setSelected(false);
                EthernetRadioButton.setEnabled(false);
                ControlPlaneRadioButton.setSelected(false);
                ControlPlaneRadioButton.setEnabled(false);

                AcceleratorRadioButton.setSelected(false);
                AcceleratorRadioButton.setEnabled(false);

            } else if (res.length() > 2 && (res.contains("8183"))) {
                acceleratorRadioButton.setSelected(true);
                acceleratorRadioButton.setEnabled(true);
                EthernetRadioButton.setSelected(false);
                EthernetRadioButton.setEnabled(false);
                ControlPlaneRadioButton.setSelected(false);
                ControlPlaneRadioButton.setEnabled(false);

                PerformanceRadioButton.setSelected(false);
                DDRgenchkRadioButton.setSelected(false);
                PerformanceRadioButton.setEnabled(false);
                DDRgenchkRadioButton.setEnabled(false);
                AcceleratorRadioButton.setSelected(true);
            } else if (res.length() > 2 && res.contains("8082")) {
                acceleratorRadioButton.setSelected(false);
                acceleratorRadioButton.setEnabled(false);
                EthernetRadioButton.setSelected(true);
                EthernetRadioButton.setEnabled(true);
                ControlPlaneRadioButton.setSelected(false);
                ControlPlaneRadioButton.setEnabled(false);

                perfGenChkRadioButton.setEnabled(true);
                perfGenChkRadioButton.setSelected(true);

                perfRawRadioButton.setSelected(false);
                perfRawRadioButton.setEnabled(false);

                PerfAppRadioButton.setEnabled(false);

            } else if (res.length() > 2 && res.contains("8182")) {
                acceleratorRadioButton.setSelected(false);
                acceleratorRadioButton.setEnabled(false);
                EthernetRadioButton.setSelected(true);
                EthernetRadioButton.setEnabled(true);
                ControlPlaneRadioButton.setSelected(false);
                ControlPlaneRadioButton.setEnabled(false);

                perfGenChkRadioButton.setEnabled(false);
                perfGenChkRadioButton.setSelected(false);

                perfRawRadioButton.setSelected(true);

            } else if (res.length() > 2 && res.contains("8011")) {
                acceleratorRadioButton.setSelected(false);
                acceleratorRadioButton.setEnabled(false);
                EthernetRadioButton.setSelected(false);
                EthernetRadioButton.setEnabled(false);
                ControlPlaneRadioButton.setSelected(true);
                ControlPlaneRadioButton.setEnabled(true);
            } else {
                acceleratorRadioButton.setSelected(false);
                acceleratorRadioButton.setEnabled(false);
                EthernetRadioButton.setSelected(false);
                EthernetRadioButton.setEnabled(false);
                ControlPlaneRadioButton.setSelected(false);
                ControlPlaneRadioButton.setEnabled(false);
                PerformanceRadioButton2.setVisible(false);
                jLabel6.setText("");
            }

            // remove the first time stamp
            if (res.length() > 2 && res.contains("8011")) {
                jLabel3.setText(res.substring(res.indexOf(" ") + 1, res.length()));
                PCIeInstallButton.setEnabled(false);
                // Display control plane.
            } else {
                ControlInstallButton.setEnabled(false);
                if (res.length() > 2 && (res.contains("8083") || res.contains("8183") || res.contains("8082") || res.contains("8182") || res.contains("8043") || res.contains("8042"))) {
                    jLabel3.setText(res.substring(res.indexOf(" ") + 1, res.length()));

                } else {
                    // disable all components
                    jLabel3.setText("No Xilinx device found with device ID 8011, 8082 or 8083");
                    PCIeInstallButton.setEnabled(false);
                }
            }

        } catch (Exception e) {
            //jTextArea1.append(e.getMessage());
        }
    }

    /**
     * This method is called from within the constructor to initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is always
     * regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        PCIeBasedAccPanel = new javax.swing.JPanel();
        PerformancePanel = new javax.swing.JPanel();
        PerformanceRadioButton = new javax.swing.JRadioButton();
        DDRgenchkRadioButton = new javax.swing.JRadioButton();
        ApplicationPanel = new javax.swing.JPanel();
        AcceleratorRadioButton = new javax.swing.JRadioButton();
        PCIeInstallButton = new javax.swing.JButton();
        jLabel5 = new javax.swing.JLabel();
        EthernetPanel = new javax.swing.JPanel();
        PerformanceEthPanel = new javax.swing.JPanel();
        PerfEthRadioButton = new javax.swing.JRadioButton();
        perfRawRadioButton = new javax.swing.JRadioButton();
        perfGenChkRadioButton = new javax.swing.JRadioButton();
        ApplicationEthPanel = new javax.swing.JPanel();
        PerfAppRadioButton = new javax.swing.JRadioButton();
        peertopeerCheckBox = new javax.swing.JCheckBox();
        EthernelInstallButton = new javax.swing.JButton();
        jLabel7 = new javax.swing.JLabel();
        ControlPlanePanel = new javax.swing.JPanel();
        ControlInstallButton = new javax.swing.JButton();
        jLabel6 = new javax.swing.JLabel();
        PerformancePanel2 = new javax.swing.JPanel();
        PerformanceRadioButton2 = new javax.swing.JRadioButton();
        backer = new javax.swing.JPanel();
        GENCHKRadioButton = new javax.swing.JRadioButton();
        HeaderPanel = new javax.swing.JPanel();
        jLabel1 = new javax.swing.JLabel();
        DeviceStatusPanel = new javax.swing.JPanel();
        SelectionPanel = new javax.swing.JPanel();
        acceleratorRadioButton = new javax.swing.JRadioButton();
        EthernetRadioButton = new javax.swing.JRadioButton();
        ControlPlaneRadioButton = new javax.swing.JRadioButton();
        ControlMainPanel = new javax.swing.JPanel();
        jLabel3 = new javax.swing.JLabel();
        jLabel2 = new javax.swing.JLabel();

        PCIeBasedAccPanel.setBorder(javax.swing.BorderFactory.createEtchedBorder());

        PerformancePanel.setBorder(javax.swing.BorderFactory.createEtchedBorder());

        PerformanceRadioButton.setSelected(true);
        PerformanceRadioButton.setText("Performance");
        PerformanceRadioButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                PerformanceRadioButtonActionPerformed(evt);
            }
        });

        DDRgenchkRadioButton.setSelected(true);
        DDRgenchkRadioButton.setText("PCIe-DMA-DDR4");
        DDRgenchkRadioButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                DDRgenchkRadioButtonActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout PerformancePanelLayout = new javax.swing.GroupLayout(PerformancePanel);
        PerformancePanel.setLayout(PerformancePanelLayout);
        PerformancePanelLayout.setHorizontalGroup(
            PerformancePanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(PerformancePanelLayout.createSequentialGroup()
                .addContainerGap()
                .addComponent(PerformanceRadioButton)
                .addContainerGap(137, Short.MAX_VALUE))
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, PerformancePanelLayout.createSequentialGroup()
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addComponent(DDRgenchkRadioButton, javax.swing.GroupLayout.PREFERRED_SIZE, 160, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(45, 45, 45))
        );
        PerformancePanelLayout.setVerticalGroup(
            PerformancePanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(PerformancePanelLayout.createSequentialGroup()
                .addContainerGap()
                .addComponent(PerformanceRadioButton)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(DDRgenchkRadioButton)
                .addContainerGap(60, Short.MAX_VALUE))
        );

        ApplicationPanel.setBorder(javax.swing.BorderFactory.createEtchedBorder());

        AcceleratorRadioButton.setText("Video Accelerator");
        AcceleratorRadioButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                AcceleratorRadioButtonActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout ApplicationPanelLayout = new javax.swing.GroupLayout(ApplicationPanel);
        ApplicationPanel.setLayout(ApplicationPanelLayout);
        ApplicationPanelLayout.setHorizontalGroup(
            ApplicationPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(ApplicationPanelLayout.createSequentialGroup()
                .addContainerGap()
                .addComponent(AcceleratorRadioButton)
                .addContainerGap(55, Short.MAX_VALUE))
        );
        ApplicationPanelLayout.setVerticalGroup(
            ApplicationPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(ApplicationPanelLayout.createSequentialGroup()
                .addContainerGap()
                .addComponent(AcceleratorRadioButton)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        PCIeInstallButton.setText("Install");
        PCIeInstallButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                PCIeInstallButtonActionPerformed(evt);
            }
        });

        jLabel5.setFont(new java.awt.Font("Tahoma", 1, 14)); // NOI18N
        jLabel5.setText("Driver Mode Selection for AXI-MM Dataplane Design");
        jLabel5.setToolTipText("");

        javax.swing.GroupLayout PCIeBasedAccPanelLayout = new javax.swing.GroupLayout(PCIeBasedAccPanel);
        PCIeBasedAccPanel.setLayout(PCIeBasedAccPanelLayout);
        PCIeBasedAccPanelLayout.setHorizontalGroup(
            PCIeBasedAccPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(PCIeBasedAccPanelLayout.createSequentialGroup()
                .addContainerGap()
                .addGroup(PCIeBasedAccPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(jLabel5, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addGroup(PCIeBasedAccPanelLayout.createSequentialGroup()
                        .addComponent(PerformancePanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(ApplicationPanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(18, 18, 18)
                        .addComponent(PCIeInstallButton)
                        .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))))
        );
        PCIeBasedAccPanelLayout.setVerticalGroup(
            PCIeBasedAccPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, PCIeBasedAccPanelLayout.createSequentialGroup()
                .addComponent(jLabel5, javax.swing.GroupLayout.PREFERRED_SIZE, 33, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addGroup(PCIeBasedAccPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, PCIeBasedAccPanelLayout.createSequentialGroup()
                        .addGroup(PCIeBasedAccPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                            .addComponent(ApplicationPanel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                            .addComponent(PerformancePanel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
                        .addContainerGap())
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, PCIeBasedAccPanelLayout.createSequentialGroup()
                        .addComponent(PCIeInstallButton)
                        .addGap(29, 29, 29))))
        );

        EthernetPanel.setBorder(javax.swing.BorderFactory.createEtchedBorder());

        PerformanceEthPanel.setBorder(javax.swing.BorderFactory.createEtchedBorder());
        PerformanceEthPanel.setPreferredSize(new java.awt.Dimension(245, 114));

        PerfEthRadioButton.setSelected(true);
        PerfEthRadioButton.setText("Performance");
        PerfEthRadioButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                PerfEthRadioButtonActionPerformed(evt);
            }
        });

        perfRawRadioButton.setText("Raw Ethernet");
        perfRawRadioButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                perfRawRadioButtonActionPerformed(evt);
            }
        });

        perfGenChkRadioButton.setSelected(true);
        perfGenChkRadioButton.setText("GEN-CHK");
        perfGenChkRadioButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                perfGenChkRadioButtonActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout PerformanceEthPanelLayout = new javax.swing.GroupLayout(PerformanceEthPanel);
        PerformanceEthPanel.setLayout(PerformanceEthPanelLayout);
        PerformanceEthPanelLayout.setHorizontalGroup(
            PerformanceEthPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(PerformanceEthPanelLayout.createSequentialGroup()
                .addGroup(PerformanceEthPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(PerformanceEthPanelLayout.createSequentialGroup()
                        .addContainerGap()
                        .addComponent(PerfEthRadioButton))
                    .addGroup(PerformanceEthPanelLayout.createSequentialGroup()
                        .addGap(56, 56, 56)
                        .addGroup(PerformanceEthPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(perfGenChkRadioButton)
                            .addComponent(perfRawRadioButton))))
                .addContainerGap(83, Short.MAX_VALUE))
        );
        PerformanceEthPanelLayout.setVerticalGroup(
            PerformanceEthPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(PerformanceEthPanelLayout.createSequentialGroup()
                .addContainerGap()
                .addComponent(PerfEthRadioButton)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(perfGenChkRadioButton)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(perfRawRadioButton)
                .addContainerGap(22, Short.MAX_VALUE))
        );

        ApplicationEthPanel.setBorder(javax.swing.BorderFactory.createEtchedBorder());

        PerfAppRadioButton.setText("Application");
        PerfAppRadioButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                PerfAppRadioButtonActionPerformed(evt);
            }
        });

        peertopeerCheckBox.setText("Peer to Peer");
        peertopeerCheckBox.setEnabled(false);

        javax.swing.GroupLayout ApplicationEthPanelLayout = new javax.swing.GroupLayout(ApplicationEthPanel);
        ApplicationEthPanel.setLayout(ApplicationEthPanelLayout);
        ApplicationEthPanelLayout.setHorizontalGroup(
            ApplicationEthPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(ApplicationEthPanelLayout.createSequentialGroup()
                .addGroup(ApplicationEthPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(ApplicationEthPanelLayout.createSequentialGroup()
                        .addContainerGap()
                        .addComponent(PerfAppRadioButton))
                    .addGroup(ApplicationEthPanelLayout.createSequentialGroup()
                        .addGap(42, 42, 42)
                        .addComponent(peertopeerCheckBox)))
                .addContainerGap(65, Short.MAX_VALUE))
        );
        ApplicationEthPanelLayout.setVerticalGroup(
            ApplicationEthPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(ApplicationEthPanelLayout.createSequentialGroup()
                .addContainerGap()
                .addComponent(PerfAppRadioButton)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(peertopeerCheckBox)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        EthernelInstallButton.setText("Install");
        EthernelInstallButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                EthernelInstallButtonActionPerformed(evt);
            }
        });

        jLabel7.setFont(new java.awt.Font("Tahoma", 1, 14)); // NOI18N
        jLabel7.setText("Driver Mode Selection for AXI Stream Dataplane Design");

        javax.swing.GroupLayout EthernetPanelLayout = new javax.swing.GroupLayout(EthernetPanel);
        EthernetPanel.setLayout(EthernetPanelLayout);
        EthernetPanelLayout.setHorizontalGroup(
            EthernetPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(EthernetPanelLayout.createSequentialGroup()
                .addContainerGap()
                .addGroup(EthernetPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addComponent(jLabel7, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addGroup(EthernetPanelLayout.createSequentialGroup()
                        .addComponent(PerformanceEthPanel, javax.swing.GroupLayout.PREFERRED_SIZE, 256, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(ApplicationEthPanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(EthernelInstallButton)
                        .addContainerGap())))
        );
        EthernetPanelLayout.setVerticalGroup(
            EthernetPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, EthernetPanelLayout.createSequentialGroup()
                .addComponent(jLabel7, javax.swing.GroupLayout.PREFERRED_SIZE, 36, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addGroup(EthernetPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, EthernetPanelLayout.createSequentialGroup()
                        .addGroup(EthernetPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING, false)
                            .addComponent(ApplicationEthPanel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                            .addComponent(PerformanceEthPanel, javax.swing.GroupLayout.DEFAULT_SIZE, 125, Short.MAX_VALUE))
                        .addContainerGap())
                    .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, EthernetPanelLayout.createSequentialGroup()
                        .addComponent(EthernelInstallButton)
                        .addGap(22, 22, 22))))
        );

        ControlPlanePanel.setBorder(javax.swing.BorderFactory.createEtchedBorder());

        ControlInstallButton.setText("Install");
        ControlInstallButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                ControlInstallButtonActionPerformed(evt);
            }
        });

        jLabel6.setFont(new java.awt.Font("Tahoma", 1, 14)); // NOI18N
        jLabel6.setText("Driver Mode Selection for Control Plane Design");

        PerformancePanel2.setBorder(javax.swing.BorderFactory.createEtchedBorder());

        PerformanceRadioButton2.setSelected(true);
        PerformanceRadioButton2.setText("Control Plane");
        PerformanceRadioButton2.setEnabled(false);
        PerformanceRadioButton2.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                PerformanceRadioButton2ActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout PerformancePanel2Layout = new javax.swing.GroupLayout(PerformancePanel2);
        PerformancePanel2.setLayout(PerformancePanel2Layout);
        PerformancePanel2Layout.setHorizontalGroup(
            PerformancePanel2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(PerformancePanel2Layout.createSequentialGroup()
                .addGap(20, 20, 20)
                .addComponent(PerformanceRadioButton2)
                .addContainerGap(334, Short.MAX_VALUE))
        );
        PerformancePanel2Layout.setVerticalGroup(
            PerformancePanel2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(PerformancePanel2Layout.createSequentialGroup()
                .addGap(21, 21, 21)
                .addComponent(PerformanceRadioButton2)
                .addContainerGap(60, Short.MAX_VALUE))
        );

        javax.swing.GroupLayout ControlPlanePanelLayout = new javax.swing.GroupLayout(ControlPlanePanel);
        ControlPlanePanel.setLayout(ControlPlanePanelLayout);
        ControlPlanePanelLayout.setHorizontalGroup(
            ControlPlanePanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(ControlPlanePanelLayout.createSequentialGroup()
                .addContainerGap()
                .addGroup(ControlPlanePanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(ControlPlanePanelLayout.createSequentialGroup()
                        .addComponent(PerformancePanel2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(ControlInstallButton)
                        .addGap(0, 15, Short.MAX_VALUE))
                    .addComponent(jLabel6, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
                .addContainerGap())
        );
        ControlPlanePanelLayout.setVerticalGroup(
            ControlPlanePanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, ControlPlanePanelLayout.createSequentialGroup()
                .addGap(0, 0, 0)
                .addComponent(jLabel6, javax.swing.GroupLayout.DEFAULT_SIZE, 39, Short.MAX_VALUE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addGroup(ControlPlanePanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                    .addComponent(ControlInstallButton)
                    .addComponent(PerformancePanel2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addGap(11, 11, 11))
        );

        GENCHKRadioButton.setText("GEN/CHK");
        GENCHKRadioButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                GENCHKRadioButtonActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout backerLayout = new javax.swing.GroupLayout(backer);
        backer.setLayout(backerLayout);
        backerLayout.setHorizontalGroup(
            backerLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(backerLayout.createSequentialGroup()
                .addGap(182, 182, 182)
                .addComponent(GENCHKRadioButton)
                .addContainerGap(187, Short.MAX_VALUE))
        );
        backerLayout.setVerticalGroup(
            backerLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, backerLayout.createSequentialGroup()
                .addContainerGap(161, Short.MAX_VALUE)
                .addComponent(GENCHKRadioButton)
                .addGap(53, 53, 53))
        );

        setDefaultCloseOperation(javax.swing.WindowConstants.EXIT_ON_CLOSE);
        setTitle("TRD Setup");
        setResizable(false);
        addWindowListener(new java.awt.event.WindowAdapter() {
            public void windowClosing(java.awt.event.WindowEvent evt) {
                formWindowClosing(evt);
            }
        });

        HeaderPanel.setBorder(javax.swing.BorderFactory.createEtchedBorder());

        jLabel1.setFont(new java.awt.Font("Tahoma", 1, 16)); // NOI18N
        jLabel1.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
        jLabel1.setText("Kintex UltraScale PCIe Reference Design");

        javax.swing.GroupLayout HeaderPanelLayout = new javax.swing.GroupLayout(HeaderPanel);
        HeaderPanel.setLayout(HeaderPanelLayout);
        HeaderPanelLayout.setHorizontalGroup(
            HeaderPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jLabel1, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
        );
        HeaderPanelLayout.setVerticalGroup(
            HeaderPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jLabel1, javax.swing.GroupLayout.Alignment.TRAILING, javax.swing.GroupLayout.DEFAULT_SIZE, 34, Short.MAX_VALUE)
        );

        javax.swing.GroupLayout DeviceStatusPanelLayout = new javax.swing.GroupLayout(DeviceStatusPanel);
        DeviceStatusPanel.setLayout(DeviceStatusPanelLayout);
        DeviceStatusPanelLayout.setHorizontalGroup(
            DeviceStatusPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 621, Short.MAX_VALUE)
        );
        DeviceStatusPanelLayout.setVerticalGroup(
            DeviceStatusPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 62, Short.MAX_VALUE)
        );

        SelectionPanel.setBorder(javax.swing.BorderFactory.createTitledBorder("Design Selection"));

        acceleratorRadioButton.setSelected(true);
        acceleratorRadioButton.setText("AXI-MM Dataplane");
        acceleratorRadioButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                acceleratorRadioButtonActionPerformed(evt);
            }
        });

        EthernetRadioButton.setText("AXI Stream Dataplane");
        EthernetRadioButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                EthernetRadioButtonActionPerformed(evt);
            }
        });

        ControlPlaneRadioButton.setText("Control Plane");
        ControlPlaneRadioButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                ControlPlaneRadioButtonActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout SelectionPanelLayout = new javax.swing.GroupLayout(SelectionPanel);
        SelectionPanel.setLayout(SelectionPanelLayout);
        SelectionPanelLayout.setHorizontalGroup(
            SelectionPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(SelectionPanelLayout.createSequentialGroup()
                .addContainerGap(26, Short.MAX_VALUE)
                .addComponent(acceleratorRadioButton, javax.swing.GroupLayout.PREFERRED_SIZE, 207, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(EthernetRadioButton, javax.swing.GroupLayout.PREFERRED_SIZE, 200, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, 32, Short.MAX_VALUE)
                .addComponent(ControlPlaneRadioButton)
                .addContainerGap(26, Short.MAX_VALUE))
        );
        SelectionPanelLayout.setVerticalGroup(
            SelectionPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(SelectionPanelLayout.createSequentialGroup()
                .addContainerGap()
                .addGroup(SelectionPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(acceleratorRadioButton)
                    .addComponent(EthernetRadioButton)
                    .addComponent(ControlPlaneRadioButton))
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        ControlMainPanel.setBorder(null);

        javax.swing.GroupLayout ControlMainPanelLayout = new javax.swing.GroupLayout(ControlMainPanel);
        ControlMainPanel.setLayout(ControlMainPanelLayout);
        ControlMainPanelLayout.setHorizontalGroup(
            ControlMainPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 0, Short.MAX_VALUE)
        );
        ControlMainPanelLayout.setVerticalGroup(
            ControlMainPanelLayout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGap(0, 162, Short.MAX_VALUE)
        );

        jLabel3.setText("Communication controller: Xilinx Corporation Device 7082");

        jLabel2.setFont(new java.awt.Font("Tahoma", 1, 12)); // NOI18N
        jLabel2.setText("Device:");

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, layout.createSequentialGroup()
                .addContainerGap()
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                    .addComponent(ControlMainPanel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addGroup(javax.swing.GroupLayout.Alignment.LEADING, layout.createSequentialGroup()
                        .addGap(12, 12, 12)
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addGroup(layout.createSequentialGroup()
                                .addComponent(jLabel2, javax.swing.GroupLayout.PREFERRED_SIZE, 88, javax.swing.GroupLayout.PREFERRED_SIZE)
                                .addGap(0, 0, Short.MAX_VALUE))
                            .addComponent(jLabel3, javax.swing.GroupLayout.DEFAULT_SIZE, 609, Short.MAX_VALUE)))
                    .addComponent(SelectionPanel, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(HeaderPanel, javax.swing.GroupLayout.Alignment.LEADING, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
                .addContainerGap())
            .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, layout.createSequentialGroup()
                    .addContainerGap()
                    .addComponent(DeviceStatusPanel, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addContainerGap()))
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addContainerGap()
                .addComponent(HeaderPanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(3, 3, 3)
                .addComponent(jLabel2, javax.swing.GroupLayout.PREFERRED_SIZE, 19, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jLabel3, javax.swing.GroupLayout.DEFAULT_SIZE, 40, Short.MAX_VALUE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(SelectionPanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(ControlMainPanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap())
            .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, layout.createSequentialGroup()
                    .addContainerGap(78, Short.MAX_VALUE)
                    .addComponent(DeviceStatusPanel, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addContainerGap(241, Short.MAX_VALUE)))
        );

        pack();
    }// </editor-fold>//GEN-END:initComponents

    private void acceleratorRadioButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_acceleratorRadioButtonActionPerformed
        // TODO add your handling code here:
        if (((JRadioButton) (evt.getSource())).isSelected() == false) {
            acceleratorRadioButton.setSelected(true);
        } else {
            ControlPlaneRadioButton.setSelected(false);

            EthernetRadioButton.setSelected(false);
            toggleDesignSelection();
        }
    }//GEN-LAST:event_acceleratorRadioButtonActionPerformed

    private void EthernetRadioButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_EthernetRadioButtonActionPerformed
        // TODO add your handling code here:
        if (((JRadioButton) (evt.getSource())).isSelected() == false) {
            EthernetRadioButton.setSelected(true);
        } else {
            acceleratorRadioButton.setSelected(false);
            ControlPlaneRadioButton.setSelected(false);
            toggleDesignSelection();
        }
    }//GEN-LAST:event_EthernetRadioButtonActionPerformed

    private void PCIeInstallButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_PCIeInstallButtonActionPerformed
        // TODO add your handling code here:
        selectedIndex = 1;
        InstallTask task = new InstallTask();
        task.delegate(this);
        task.execute();
        showLoadingScreen("Installing Device Drivers...Please wait...");

        // Actions to be performed after successful installation of driver.

    }//GEN-LAST:event_PCIeInstallButtonActionPerformed

    private void EthernelInstallButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_EthernelInstallButtonActionPerformed
        // TODO add your handling code here:
//        lander.setVisible(false);
//        MainScreen ms = MainScreen.getInstance();
        selectedIndex = 2;
        InstallTask task = new InstallTask();
        task.delegate(this);
        task.execute();
        showLoadingScreen("Installing Device Drivers...Please wait...");

    }//GEN-LAST:event_EthernelInstallButtonActionPerformed

    private void ControlInstallButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_ControlInstallButtonActionPerformed
        // TODO add your handling code here:
        selectedIndex = 3;
        InstallTask task = new InstallTask();
        task.delegate(this);
        task.execute();
        showLoadingScreen("Installing Device Drivers...Please wait...");
    }//GEN-LAST:event_ControlInstallButtonActionPerformed

    private void ControlPlaneRadioButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_ControlPlaneRadioButtonActionPerformed
        // TODO add your handling code here:
        if (((JRadioButton) (evt.getSource())).isSelected() == false) {
            ControlPlaneRadioButton.setSelected(true);

        } else {
            acceleratorRadioButton.setSelected(false);
            EthernetRadioButton.setSelected(false);
            toggleDesignSelection();
        }
    }//GEN-LAST:event_ControlPlaneRadioButtonActionPerformed

    private void AcceleratorRadioButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_AcceleratorRadioButtonActionPerformed
        // TODO add your handling code here:
        // uncheck the performance mode. and change the title
        if (((JRadioButton) (evt.getSource())).isSelected() == false) {
            AcceleratorRadioButton.setSelected(true);
        }
        PerformanceRadioButton.setSelected(false);
        GENCHKRadioButton.setSelected(false);
        DDRgenchkRadioButton.setSelected(false);
        GENCHKRadioButton.setEnabled(false);
        DDRgenchkRadioButton.setEnabled(false);

    }//GEN-LAST:event_AcceleratorRadioButtonActionPerformed

    private void PerformanceRadioButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_PerformanceRadioButtonActionPerformed
        // TODO add your handling code here:
        if (((JRadioButton) (evt.getSource())).isSelected() == false) {
            PerformanceRadioButton.setSelected(true);

        }
        GENCHKRadioButton.setEnabled(true);
        DDRgenchkRadioButton.setEnabled(true);
        DDRgenchkRadioButton.setSelected(true);
        AcceleratorRadioButton.setSelected(false);
//        DDRgenchkRadioButton.setSelected(true);
    }//GEN-LAST:event_PerformanceRadioButtonActionPerformed

    private void GENCHKRadioButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_GENCHKRadioButtonActionPerformed
        // TODO add your handling code here:
        if (((JRadioButton) (evt.getSource())).isSelected() == false) {
            GENCHKRadioButton.setSelected(true);
        }
        DDRgenchkRadioButton.setSelected(false);
    }//GEN-LAST:event_GENCHKRadioButtonActionPerformed

    private void DDRgenchkRadioButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_DDRgenchkRadioButtonActionPerformed
        // TODO add your handling code here:
        if (((JRadioButton) (evt.getSource())).isSelected() == false) {
            DDRgenchkRadioButton.setSelected(true);
        }
        GENCHKRadioButton.setSelected(false);
    }//GEN-LAST:event_DDRgenchkRadioButtonActionPerformed

    private void PerfAppRadioButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_PerfAppRadioButtonActionPerformed
        // TODO add your handling code here:
        if (((JRadioButton) (evt.getSource())).isSelected() == false) {
            PerfAppRadioButton.setSelected(true);
        }
        peertopeerCheckBox.setEnabled(true);
        PerfEthRadioButton.setSelected(false);
        perfRawRadioButton.setSelected(false);
        perfRawRadioButton.setEnabled(false);
        perfGenChkRadioButton.setSelected(false);
        perfGenChkRadioButton.setEnabled(false);

    }//GEN-LAST:event_PerfAppRadioButtonActionPerformed

    private void PerfEthRadioButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_PerfEthRadioButtonActionPerformed
        // TODO add your handling code here:

        if (((JRadioButton) (evt.getSource())).isSelected() == false) {
            PerfEthRadioButton.setSelected(true);

        }
        PerfAppRadioButton.setSelected(false);
        peertopeerCheckBox.setSelected(false);
        peertopeerCheckBox.setEnabled(false);
        perfRawRadioButton.setEnabled(true);
        perfRawRadioButton.setSelected(true);
        perfGenChkRadioButton.setEnabled(false);
        perfGenChkRadioButton.setSelected(false);
    }//GEN-LAST:event_PerfEthRadioButtonActionPerformed

    private void perfGenChkRadioButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_perfGenChkRadioButtonActionPerformed
        // TODO add your handling code here:
        if (((JRadioButton) (evt.getSource())).isSelected() == false) {
            perfGenChkRadioButton.setSelected(true);

        }
        perfRawRadioButton.setSelected(false);

    }//GEN-LAST:event_perfGenChkRadioButtonActionPerformed

    private void perfRawRadioButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_perfRawRadioButtonActionPerformed
        // TODO add your handling code here:
        if (((JRadioButton) (evt.getSource())).isSelected() == false) {
            perfRawRadioButton.setSelected(true);

        }
        perfGenChkRadioButton.setSelected(false);
    }//GEN-LAST:event_perfRawRadioButtonActionPerformed

    private void formWindowClosing(java.awt.event.WindowEvent evt) {//GEN-FIRST:event_formWindowClosing
    }//GEN-LAST:event_formWindowClosing

    private void PerformanceRadioButton2ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_PerformanceRadioButton2ActionPerformed
        // TODO add your handling code here:
    }//GEN-LAST:event_PerformanceRadioButton2ActionPerformed

    /**
     * @param args the command line arguments
     */
    public static void main(String args[]) {
        /* Set the Nimbus look and feel */
        //<editor-fold defaultstate="collapsed" desc=" Look and feel setting code (optional) ">
        /* If Nimbus (introduced in Java SE 6) is not available, stay with the default look and feel.
         * For details see http://download.oracle.com/javase/tutorial/uiswing/lookandfeel/plaf.html 
         */
        try {
            /*for (javax.swing.UIManager.LookAndFeelInfo info : javax.swing.UIManager.getInstalledLookAndFeels()) {
             if ("Nimbus".equals(info.getName())) {
             javax.swing.UIManager.setLookAndFeel(info.getClassName());
             break;
             }
             }*/
            UIManager.setLookAndFeel(new NimbusLookAndFeel());
        } catch (Exception ex) {
            java.util.logging.Logger.getLogger(LandingPage.class.getName()).log(java.util.logging.Level.SEVERE, null, ex);
        }
        //</editor-fold>

        /* Create and display the form */
        java.awt.EventQueue.invokeLater(new Runnable() {
            public void run() {
                // check for instance running
                RmiManager rmiManager = new RmiManager();
                rmiManager.createRmiRegistry();

                if (rmiManager.isAlreadyRunning()) {
                    Object[] options1 = {"Ok"};
                    int s = JOptionPane.showOptionDialog(null, "Another instance of GUI is running.", " ",
                            JOptionPane.CLOSED_OPTION, JOptionPane.WARNING_MESSAGE,
                            null, options1, null);

                    System.exit(0);
                    return;
                }

                try {
                    rmiManager.registerApplication();
                } catch (AlreadyBoundException ex) {
                }

                /// no other instance is running
                lander = new LandingPage();
                lander.setVisible(true);
                lander.setSizesOfDynamicPanels();
                lander.toggleDesignSelection();
                // add PCIe to the bottom panel.
                lander.makeDialog();

            }
        });
    }

    public void setSizesOfDynamicPanels() {
        EthernetPanel.setSize(ControlMainPanel.getSize().width - 10, ControlMainPanel.getSize().height);
        PCIeBasedAccPanel.setSize(ControlMainPanel.getSize().width - 10, ControlMainPanel.getSize().height);
        ControlPlanePanel.setSize(ControlMainPanel.getSize().width - 10, ControlMainPanel.getSize().height);

    }

    public void hideLP() {
        setVisible(false);
    }

    public void showLP() {
        setVisible(true);
    }

    public void toggleDesignSelection() {
        ControlMainPanel.removeAll();
        if (acceleratorRadioButton.isSelected() == true) {
            ControlMainPanel.add(PCIeBasedAccPanel);
        } else if (EthernetRadioButton.isSelected() == true) {
            ControlMainPanel.add(EthernetPanel);
        } else {
            ControlMainPanel.add(ControlPlanePanel);
        }
        ControlMainPanel.repaint();
        ControlMainPanel.revalidate();
    }
    static LandingPage lander;
    int selectedIndex;
    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JRadioButton AcceleratorRadioButton;
    private javax.swing.JPanel ApplicationEthPanel;
    private javax.swing.JPanel ApplicationPanel;
    private javax.swing.JButton ControlInstallButton;
    private javax.swing.JPanel ControlMainPanel;
    private javax.swing.JPanel ControlPlanePanel;
    private javax.swing.JRadioButton ControlPlaneRadioButton;
    private javax.swing.JRadioButton DDRgenchkRadioButton;
    private javax.swing.JPanel DeviceStatusPanel;
    private javax.swing.JButton EthernelInstallButton;
    private javax.swing.JPanel EthernetPanel;
    private javax.swing.JRadioButton EthernetRadioButton;
    private javax.swing.JRadioButton GENCHKRadioButton;
    private javax.swing.JPanel HeaderPanel;
    private javax.swing.JPanel PCIeBasedAccPanel;
    private javax.swing.JButton PCIeInstallButton;
    private javax.swing.JRadioButton PerfAppRadioButton;
    private javax.swing.JRadioButton PerfEthRadioButton;
    private javax.swing.JPanel PerformanceEthPanel;
    private javax.swing.JPanel PerformancePanel;
    private javax.swing.JPanel PerformancePanel2;
    private javax.swing.JRadioButton PerformanceRadioButton;
    private javax.swing.JRadioButton PerformanceRadioButton2;
    private javax.swing.JPanel SelectionPanel;
    private javax.swing.JRadioButton acceleratorRadioButton;
    private javax.swing.JPanel backer;
    private javax.swing.JLabel jLabel1;
    private javax.swing.JLabel jLabel2;
    private javax.swing.JLabel jLabel3;
    private javax.swing.JLabel jLabel5;
    private javax.swing.JLabel jLabel6;
    private javax.swing.JLabel jLabel7;
    private javax.swing.JCheckBox peertopeerCheckBox;
    private javax.swing.JRadioButton perfGenChkRadioButton;
    private javax.swing.JRadioButton perfRawRadioButton;
    // End of variables declaration//GEN-END:variables
    JDialog modalDialog = new JDialog(this, "Busy", ModalityType.DOCUMENT_MODAL);
    JLabel loadingMessage;

    private void makeDialog() {
        modalDialog.setLayout(new BorderLayout());
        loadingMessage = new JLabel("", JLabel.CENTER);
        modalDialog.add(loadingMessage, BorderLayout.CENTER);
        modalDialog.setSize(400, 150);
        modalDialog.setLocationRelativeTo(this);
    }

    private int executeShellScript(String cmd) {
        int exitValue = -10;
        try {
            Runtime runtime = Runtime.getRuntime();
            Process process = runtime.exec(new String[]{"/bin/bash", "-c", cmd});
            exitValue = process.waitFor();

        } catch (Exception e) {
            //jTextArea1.append(e.getMessage());
            e.printStackTrace();
        }
        return exitValue;
    }

    class InstallTask extends SwingWorker<Void, Void> {

        String imgName = "";
        LandingPage landingPageLocal;
        int retVal = -1;

        public void delegate(LandingPage lp) {
            landingPageLocal = lp;
        }

        @Override
        protected Void doInBackground() throws Exception {
            // For acceleration mode.. video
            if (selectedIndex == 1 && AcceleratorRadioButton.isSelected() == true) {
                retVal = executeShellScript("./run_video_app.sh");
            } else if (selectedIndex == 2) {
                if (PerfAppRadioButton.isSelected() == true) {
                    if (peertopeerCheckBox.isSelected()) {
                        retVal = executeShellScript("./run_eth_app_p2p.sh");//remove_modules
                    } else {
                        retVal = executeShellScript("./run_eth_app.sh");//remove_modules}
                    }
                } else if (perfRawRadioButton.isSelected() == true) {
                    // performnce  -- raw eth
                    retVal = executeShellScript("./run_raw_ethermode.sh");
                } else {
                    // performance -- gencheck 
                    retVal = executeShellScript("./run_perf_mode.sh");//remove_modules
                }
            } else {
                retVal = executeShellScript("./run_perf_mode.sh");//remove_modules
            }
            //System.out.println("executed the script ::  " + retVal);

            return null;
        }

        @Override
        public void done() {

            modalDialog.setVisible(false);
            if (retVal != 0) {
                JOptionPane.showMessageDialog(lander, "Driver installation failed.");
                return;
            }
            Object[] options = {"View Log", "Ok"};
            int n = 0;
            lander.setVisible(false);
            MainScreen ms = MainScreen.getInstance();;

            // for accelerator
            if (selectedIndex == 1) {
                if (PerformanceRadioButton.isSelected()) {
                    if (GENCHKRadioButton.isSelected() == true) {
                        ms.configureScreen(0, landingPageLocal);
                        ms.loadDataPathForoneDP();
                        ms.loadAllGraphs();
                    } else {
                        ms.configureScreen(1, landingPageLocal);
                        ms.loadDataPathForoneDPRDWDP();
                        ms.loadAllGraphs();
                    }

                } else {

                    // Accelerator mode
                    MainScreen_video ms2 = MainScreen_video.getInstance();

                    ms2.configureScreen(2, landingPageLocal);
                    ms2.loadVideo();
                    ms2.setVisible(true);
                    ms2.loadAllGraphs();
                    return;
                }
            } else if (selectedIndex == 2) { // for Ethernet AXI Stream.

                if (PerfAppRadioButton.isSelected()) {
                    ms.removeStatsPanel();
                    ms.configureScreen(4, landingPageLocal);
                    ms.loadDataPath();
                    ms.loadAllGraphs();

                } else {
                    ms.removeStatsPanel();
                    if (perfRawRadioButton.isSelected()) {
                        ms.configureScreen(3, landingPageLocal);
                        ms.loadDataPath();
                        ms.loadAllGraphs();
                    } else {
                        ms.configureScreen(7, landingPageLocal);
                        ms.loadDataPath();
                        ms.loadAllGraphs();
                    }
                }

            } else if (selectedIndex == 3) { // for control panel
//                lander.setVisible(false);
                ms.configureScreen(6, landingPageLocal);
                ms.loadReadWriteCmd();
                ms.loadAllGraphs();
            }

            ms.setVisible(true);

//            ms.loadAllGraphs();
        }
    }

    class uInstallTask extends SwingWorker<Void, Void> {

        String imgName = "";
        MainScreen ms;

        public void delegate(MainScreen msc) {
            ms = msc;
        }

        @Override
        protected Void doInBackground() throws Exception {
            if (Develop.production == 1) {
                /*Runtime runtime = Runtime.getRuntime();
                 Process process = runtime.exec(new String[]{"/bin/bash", "-c", "./remove_modules.sh"});
                 //process.waitFor();
                 java.io.InputStream stdin = process.getInputStream();
                 java.io.InputStreamReader isr = new java.io.InputStreamReader(stdin);
                 java.io.BufferedReader br = new java.io.BufferedReader(isr);
                 String line = null;
                 while ( (line = br.readLine()) != null)
                 System.out.println(line);*/

                int retVal = executeShellScript("./remove_modules.sh");//run_perf_mode
//                System.out.println("executed the script remove modules ::  " + retVal);
            }
            return null;
        }

        @Override
        public void done() {
            //modalDialog.setVisible(false);
            ms.unInstallDone();

        }
    }

    class uInstallTaskVideo extends SwingWorker<Void, Void> {

        String imgName = "";
        MainScreen_video ms;

        public void delegate(MainScreen_video msc) {
            ms = msc;
        }

        @Override
        protected Void doInBackground() throws Exception {
            if (Develop.production == 1) {
                /*Runtime runtime = Runtime.getRuntime();
                 Process process = runtime.exec(new String[]{"/bin/bash", "-c", "./remove_modules.sh"});
                 //process.waitFor();
                 java.io.InputStream stdin = process.getInputStream();
                 java.io.InputStreamReader isr = new java.io.InputStreamReader(stdin);
                 java.io.BufferedReader br = new java.io.BufferedReader(isr);
                 String line = null;
                 while ( (line = br.readLine()) != null)
                 System.out.println(line);*/

                int retVal = executeShellScript("./remove_modules.sh");//run_perf_mode
//                System.out.println("executed the script remove modules ::  " + retVal);
            }
            return null;
        }

        @Override
        public void done() {
            //modalDialog.setVisible(false);
            ms.unInstallDone();

        }
    }

    private void showLoadingScreen(String message) {
        loadingMessage.setText(message);
        modalDialog.setVisible(true);
    }

    public void uninstallDrivers(MainScreen ms) {
        uInstallTask utask = new uInstallTask();
        utask.delegate(ms);
        utask.execute();
    }

    public void uninstallDrivers(MainScreen_video ms) {
        uInstallTaskVideo utask = new uInstallTaskVideo();
        utask.delegate(ms);
        utask.execute();
    }
}
