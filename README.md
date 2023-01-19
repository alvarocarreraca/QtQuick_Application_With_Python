The stroke is a condition where the blood supply to the brain is disrupted, therefore turning
into oxygen starvation, brain damage and loss of function. Not only it is leading cause of
mortality worldwide, but also among the survivors there is a high percentage that experi
ence post stroke neural injuries. The most common one is upper limb unilateral paresis,
affecting to more than 80% of the survivors.
Functional Electrical Stimulation (FES) is a technique used to rehabilitate the post stroke
patients looking for speeding up the recovery process. The Brain Computer Interface
Group from Danmarks Tekniske Universitet (DTU) has developed a FESbased prototype
for neurorehabilitation, named MyoFES, that is oriented for upper limb rehabilitation ther
apies. This prototype, that was tested to work properly in [1], it is hardwarebased, thus
its use is extremely limited.
The present work focuses on the development of a Graphical User Interface (GUI) for
desktop use that interfaces the MyoFES and the users. This GUI, named TransRehab,
will be developed in Python (backend) and QML (frontend). In addition, it will be de
signed and developed a portable acquisition module with wireless data transmission ca
pability that will enable to exchange information between MyoFES and TransRehab. This
wireless communication will be based on Bluetooth protocol. Lastly, a signal processing
routine based on the event detection of an electromyography (EMG) signal will be imple
mented to control the therapy.
The final step of the present work will be to integrate both systems (i.e. MyoFES and
TransRehab), and validate the correct performance of the integration. The most critical
point of the integration will be the communication channel management, due to the fact
that enables twoways communication. In addition, the visualization on real time of the
signals captured by MyoFES will be tested to confirm that there is consistence on the
information shown in TransRehab. To conclude, a therapy will be simulated over a test
group, to test all the functionalities of TransRehab and verify the robustness of the event
detection routine.
