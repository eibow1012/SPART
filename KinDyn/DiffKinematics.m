function [Bij,Bi0,P0,pm]=DiffKinematics(R0,r0,rL,e,g,robot) %#codegen
% Computes the differential kineamtics of a serial manipulator.
%
% Input ->
%   R0 -> Rotation matrix from the base-spacecraft to the inertial frame.
%   r0 -> Position of the base-spacecraft to the inertial frame.
%   rL -> Position of links.
%   e -> Joint axis.
%   g -> Vector from joint to link center-of-mass
%   robot -> Robot model.
%
% Output ->
%   Bij -> Twist-propagation matrix (for manipulator i>0 and j>0).
%   Bi0 -> Twist-propagation matrix (for i>0 and j=0).
%   P0 -> Base-spacecraft twist-propagation vector.
%   pm -> Manipulator twist-propagation vector.

%=== LICENSE ===%

%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU Lesser General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU Lesser General Public License for more details.
% 
%     You should have received a copy of the GNU Lesser General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.

%=== CODE ===%

%--- Number of links  ---%
n=robot.n_links_joints;

%--- Twist-propagtaion matrix ---%

%Pre-allocate Bij
if not(isempty(coder.target)) %Only use during code generation (allowing symbolic computations)
    Bij=zeros(6,6,n,n);
end

%Compute Bij
for j=1:n
    for i=1:n
        if robot.con.branch(i,j)==1
            %Links are in the same branch
            Bij(1:6,1:6,i,j)=[eye(3), zeros(3,3); SkewSym(rL(1:3,j)-rL(1:3,i)), eye(3)];
        else
            %Links are not in the same branch
            Bij(1:6,1:6,i,j)=zeros(6,6);
        end
    end
end

%Pre-allocate Bi0
if not(isempty(coder.target)) %Only use during code generation (allowing symbolic computations)
    %Pre-allocate Bi0
    Bi0=zeros(6,6,n);
end

%Compute Bi0
for i=1:n
    Bi0(1:6,1:6,i)=[eye(3), zeros(3,3); SkewSym(r0-rL(1:3,i)), eye(3)];
end

%--- Twist-Propagation vector ---%

%Pre-allocate pm
if not(isempty(coder.target)) %Only use during code generation (allowing symbolic computations)
    %Pre-allocate
    pm=zeros(6,n);
end

%Base-spacecraft
P0=[R0,zeros(3,3); zeros(3,3), eye(3)];

%Forward recursion to obtain the Twist-Propagation vector
for i=1:n
    if robot.joints(i).type==1
        %Revolute joint
        pm(1:6,i)=[e(1:3,i);cross(e(1:3,i),g(1:3,i))];
    elseif robot.joints(i).type==2
        %Prismatic joint
        pm(1:6,i)=[zeros(3,1);e(1:3,i)];
    elseif robot.joints(i).type==0
        %Fixed joint
        pm(1:6,i)=zeros(6,1);
    end
end

end







