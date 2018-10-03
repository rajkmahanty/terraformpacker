#!/usr/bin/env groovy
import groovy.json.JsonSlurperClassic

node {
    stage('Pull') {
	tool name: 'jdk8', type: 'jdk'
	tool name: 'maven', type: 'maven'
	def mvnHome = tool 'maven'
	env.PATH = "${mvnHome}/bin:${env.PATH}"    
        checkout scm
    }

    stage('Build') {        
        sh "mvn -f complete/pom.xml clean install -DskipTests=true"
    }

    stage('Packer') {
	def Build = false;
	try {
		input message: 'Build?', ok: 'Build'
		Build = true
		} catch (err) {
		Build = false
		currentBuild.result = 'SUCCESS'
	}
	
       if (Build){   
	 def pcHome = tool name: 'Packer', type: 'com.cloudbees.jenkins.plugins.customtools.CustomTool'
         env.PATH = "${pcHome}:${env.PATH}"
	  sh "cd ${pwd()}/packer;packer build -var-file=/home/devops/terraform-packer/packer/templates.json"
        }
    }	
	
    stage('Terraform'){
	def Apply = false;
	try {
	    input message: 'Apply?', ok: 'Apply'
	    Apply = true
	   } catch (err) {
	     Apply = false
	     currentBuild.result = 'SUCCESS'
	  }
	
       if (Apply){    
	 def tfHome = tool name: 'Terraform', type: 'com.cloudbees.jenkins.plugins.customtools.CustomTool'
         env.PATH = "${tfHome}:${env.PATH}"
         sh "cd /home/devops/terraform-packer/terraform/;terraform init;terraform apply --auto-approve;terraform output --json > terraform.json"
       }
    }
	
    stage('Inspec Testing') {
	def RunTest = false;
	try {
	    input message: 'RunTest?', ok: 'RunTest'
	    RunTest = true
	   } catch (err) {
	     RunTest = false
	     currentBuild.result = 'SUCCESS'
	  }
	
       if (RunTest){    
	 try {		    
	   def inputFile = new File(pwd()+"/terraform/terraform.json")
     	   def InputJSON = new JsonSlurperClassic().parseText(inputFile.text)
     	   def IPAddress = InputJSON.public_ip_address.value
     	   echo "IP Address: "+IPAddress
     	   sh "inspec exec cis_tests.rb --reporter cli junit:junit.xml -t ssh://devops@${IPAddress} -i /home/devops/.ssh/id_rsa"					
	 } catch(err) {
	   echo "Some Tests Failed! "+err
	 } finally {
	   junit 'junit.xml'
	 }
       }	
    }	
   
   stage('Terraform Teardown'){
	def Teardown = false;
	try {
	    input message: 'Teardown?', ok: 'Teardown'
	    Teardown = true
	   } catch (err) {
	     Teardown = false
	     currentBuild.result = 'SUCCESS'
	  }
	
       if (Teardown){    
	 def tfHome = tool name: 'Terraform', type: 'com.cloudbees.jenkins.plugins.customtools.CustomTool'
         env.PATH = "${tfHome}:${env.PATH}"
         sh "cd /home/devops/terraform-packer/terraform/;terraform destroy --force"
       }
    }	
   	
 }
