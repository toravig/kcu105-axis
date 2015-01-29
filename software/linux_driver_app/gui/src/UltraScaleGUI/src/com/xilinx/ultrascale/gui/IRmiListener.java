package com.xilinx.ultrascale.gui;

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author xhdpssa
 */
import java.rmi.Remote;
import java.rmi.RemoteException;

public interface IRmiListener extends Remote {
    boolean isAlreadyRunning() throws RemoteException;
}